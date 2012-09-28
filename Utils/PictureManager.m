//
//  PictureManager.m
//  iKnow
//
//  Created by curer on 11-9-11.
//  Copyright 2011 iKnow Team. All rights reserved.
//

#import "PictureManager.h"

#define MAX_THUMB_PICTURE_SIZE        200

@implementation PictureManager

+ (UIImage *)scaleAndRotateImage:(UIImage *)image andMaxLen:(int)kMaxResolution {
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (BOOL)CreateThumbByImagePath:(NSString *)path{
    if (path == nil) {
        return NO;
    }
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    UIImage* thumbImage = [self scaleAndRotateImage:image andMaxLen:MAX_THUMB_PICTURE_SIZE];
    
    // now grab the PNG representation of our image
    NSData *thumbData = UIImageJPEGRepresentation(thumbImage, 1);
    // now finally we can write our new thumbnail to the tmp directory on the phone.
    NSString *writePath = [NSString stringWithFormat:@"%@.th", path];
    [thumbData writeToFile:writePath atomically:YES];
    
    [image release];
    //[myThumbNail release];
    
    return YES;
}
 
+ (UIImage *)GetThumbImageByImagePath:(NSString*)path {
    if ([path length] == 0) {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:path])
    {
        return nil;
    }
    
    NSString *thumbPath = [NSString stringWithFormat:@"%@.th", path];
    if (![fileManager fileExistsAtPath:thumbPath])
    {
        //缩略图不存在 ，我们创建
        if (![self CreateThumbByImagePath:path]) {
            return nil;
        }
    }
    
    return [UIImage imageWithContentsOfFile:thumbPath];
}

+ (CGSize)GetImageSize:(UIImage *)image {
    if (image == nil) {
        return CGSizeMake(0,0);
    }
    
    CGImageRef imageRef = [image CGImage];
    
    int _width = CGImageGetWidth(imageRef);
    int _height = CGImageGetHeight(imageRef);
    
    return CGSizeMake(_width, _height);
}

@end
