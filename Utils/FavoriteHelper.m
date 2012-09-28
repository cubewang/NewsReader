//
//  FavoriteHelper.m
//  EnglishFun
//
//  Created by Cube Wang on 12-7-16.
//  Copyright (c) 2012年 iKnow Team. All rights reserved.
//

#import "FavoriteHelper.h"
#import "iFavorite.h"
#import "Article.h"

static const int ddLogLevel = LOG_FLAG_ERROR;

@implementation FavoriteHelper

@synthesize context;

#pragma mark -
#pragma mark Initialization

static FavoriteHelper* _instance = nil;

+ (FavoriteHelper*) instance
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[FavoriteHelper alloc] init];
        }
    }
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {

        [self initHelper];
    }
    
    return self;
}

- (void)initHelper
{
    self.context = [[[EnglishFunAppDelegate sharedAppDelegate] getClient] getContext];
}


+ (id)alloc
{
	@synchronized([FavoriteHelper class])
	{
		NSAssert(_instance == nil, @"Attempted to allocate a second instance of a LeftViewController.");
		_instance = [super alloc];
        
		return _instance;
	}
    
	return nil;
}

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized([FavoriteHelper class]) 
    {
        if (_instance == nil) 
        {            
            // assignment and return on first allocation
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    } 
    //on subsequent allocation attempts return nil
    return nil; 
} 

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
} 

- (unsigned)retainCount
{
    //denotes an object that cannot be released
    return UINT_MAX;  
} 

- (void)release
{
    //do nothing
} 

- (id)autorelease
{
    return self;
}


#pragma mark -
#pragma mark CoreData

- (NSFetchedResultsController *)getFetchedResultsController:(NSString *)articleId
{
    NSFetchedResultsController *fetchedResultsController = nil;

    @synchronized([FavoriteHelper class]) 
    {
        // Init a fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"iFavorite" inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
        
        // Apply an ascending sort for items
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
        NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
        [fetchRequest setSortDescriptors:descriptors];
        
        // Recover query
        if (articleId && articleId.length) 
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"articleId ==[cd] %@", articleId];
        
        // Init the fetched results controller
        NSError *error;
        fetchedResultsController = [[NSFetchedResultsController alloc] 
                                    initWithFetchRequest:fetchRequest 
                                    managedObjectContext:self.context 
                                    sectionNameKeyPath:nil
                                    cacheName:nil];
        fetchedResultsController.delegate = self;
        
        if (![fetchedResultsController performFetch:&error])    
            DDLogError(@"Error: %@", [error localizedDescription]);
        
        [fetchRequest release];
        [sortDescriptor release];
    }
    
    return [fetchedResultsController autorelease];
}

- (BOOL)isFavorite:(NSString *)articleId
{
    NSFetchedResultsController *fetchedResultsController = [self getFetchedResultsController:articleId];
    
    if (fetchedResultsController == nil)
        return NO;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];   
    
    if ([sectionInfo numberOfObjects] == 1)
    {
        NSString *key = [[[sectionInfo objects] objectAtIndex:0] valueForKey:@"articleId"];
        if ([key isEqualToString:articleId]) {
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)addFavorite:(Article *)newFavorite
{
    if (newFavorite == nil) 
        return FALSE;
    
    if ([self isFavorite:newFavorite.Id]) {
        return YES;
    }
    
    @synchronized([FavoriteHelper class]) 
    {
        // build a new iFavorite and set its field
        iFavorite *favorite = (iFavorite *)[NSEntityDescription 
                                            insertNewObjectForEntityForName:@"iFavorite" 
                                            inManagedObjectContext:self.context];
        favorite.provider = newFavorite.UserName;
        favorite.name = newFavorite.Name;
        favorite.articleId = newFavorite.Id;
        favorite.articleDescription = newFavorite.Description;
        favorite.imageUrl = newFavorite.ImageUrl;
        favorite.contentType = [NSString stringWithFormat:@"%d", newFavorite.Type];
        favorite.openCount = newFavorite.OpenCount;
        
        if ([newFavorite.Tags count] > 1)
        {
            favorite.contentTags = [NSString stringWithFormat:@"%@,%@", [newFavorite.Tags objectAtIndex:0], [newFavorite.Tags objectAtIndex:1]];
        }
        else if ([newFavorite.Tags count] == 1) {
            favorite.contentTags = [NSString stringWithFormat:@"%@", [newFavorite.Tags objectAtIndex:0]];
        }
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString* dateString = [dateFormat stringFromDate:date];
        favorite.createDate = dateString;
        
        [dateFormat release];
        
        //同步收藏
        BOOL result = [iKnowAPI addFavorite:newFavorite];
        
        if (!result) {
            DDLogError(@"addFavorite failed.");
        }
    }
    
    // save the new item
    NSError *error; 
    if (![self.context save:&error])
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        
        return FALSE;
    }
    else {
        
        return TRUE;
    }
}

- (BOOL)deleteFavorite:(NSString *)articleId
{
    NSFetchedResultsController *fetchedResultsController = [self getFetchedResultsController:articleId];
    
    if (fetchedResultsController == nil)
        return NO;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
    if ([sectionInfo numberOfObjects] == 0) {
        
        return TRUE;
    }
    
    BOOL result = [iKnowAPI deleteFavorite:articleId];
    
    if (!result) {
        DDLogError(@"deleteFavorite failed.");
    }
    
    NSError *error = nil;
    [self.context deleteObject:[[sectionInfo objects] objectAtIndex:0]];
    if (![self.context save:&error])
    {
        DDLogError(@"Error: %@", [error localizedDescription]);
        
        return FALSE;
    }
    else {
        
        return TRUE;
    }
}

@end
