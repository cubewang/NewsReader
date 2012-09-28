//
//  MessageManager.h
//  iKnow
//
//  Created by curer on 11-7-21.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "GCDMulticastDelegate.h"
#import "FileTransferEx.h"
#import "XMPPiKnowStorage.h"
#import <AVFoundation/AVFoundation.h>

@class MessageManager;
@class XMPPMessage;
@class MessageCoreDataObject;
@class SessionCoreDataObject;

@protocol MessageDelegate <NSObject>
- (void)MessageManager:(MessageManager *)sender didReceivedMessage:(MessageCoreDataObject *)message;
- (void)MessageManager:(MessageManager *)sender didSendMessageIdentify:(NSString *)identify;
- (void)MessageManager:(MessageManager *)sender 
didSendMessageIdentify:(NSString *)identify 
             withError:(NSString *)error;

@end

@interface MessageManager : NSObject < NSFetchedResultsControllerDelegate >
{
    FileTransferEx *fileTransferEx;
    
    GCDMulticastDelegate <MessageDelegate> *multicastMessageDelegate;
    
    XMPPiKnowStorage *xmppiKnowStorage;
    
    AVAudioPlayer *player;
}

@property (retain, readonly) XMPPiKnowStorage *xmppiKnowStorage;

+ (BOOL)allowToSendOrReveiveMessage:(NSString *)userID;

- (id)initWithUserInfoCoreDataStorage:(XMPPiKnowStorage *)xmppiKnowStorage;

- (BOOL)SendMessageToId:(NSString *)userID 
                andText:(NSString *)text 
            andIdentify:(NSString *)identify;

- (BOOL)SendMessage:(MessageCoreDataObject *)message 
    andProgressView:(UIProgressView *)view; 

- (SessionCoreDataObject *) newSessionWithId:(NSString *)userId;

- (int) QueryUnReadMsgCount;
- (void)handleReceivedXMPPMessage:(XMPPMessage *)message;

- (void)handleDidSendMessage:(XMPPMessage *)xmppMessage;

- (void)addDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;

@end
