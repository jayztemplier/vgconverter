//
//  VGConverter.m
//  FitCoach
//
//  Created by Jeremy Templier on 4/28/15.
//  Copyright (c) 2015 Jeremy Templier. All rights reserved.
//

#import "VGConverter.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+vImageScaling.h"

@implementation VGConverter

+ (instancetype)converter {
    static VGConverter *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

- (void)gifFromVideoAtURL:(NSURL *)url size:(CGSize)size qualityCompression:(CGFloat)compression completion:(void (^)(NSURL* fileURL , NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *fileProperties = @{
                                         (__bridge id)kCGImagePropertyGIFDictionary: @{
                                                 (__bridge id)kCGImagePropertyGIFLoopCount: @0,
                                                 }
                                         };
        
        NSDictionary *frameProperties = @{
                                          (__bridge id)kCGImagePropertyGIFDictionary: @{
                                                  (__bridge id)kCGImagePropertyGIFDelayTime: @(1.f/15.f),
                                                  }
                                          };
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
        
        NSMutableArray * images = [NSMutableArray array];
        [self imagesForVideoAtURL:url size:size qualityCompression:compression completion:^(UIImage *image, BOOL isDone) {
            if (image) {
                [images addObject:image];
            }
            if (isDone) {
                CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, [images count], NULL);
                CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
                for (int i = 0; i < images.count; i++) {
                    UIImage *image = images[i];
                    if (image) {
                        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
                    }
                }
                if (!CGImageDestinationFinalize(destination)) {
                    NSLog(@"failed to finalize image destination");
                }
                CFRelease(destination);
                completion(fileURL,nil);
            }
        }];
    });
}

- (void)imagesForVideoAtURL:(NSURL *)url size:(CGSize)size qualityCompression:(CGFloat)compression completion:(void (^)(UIImage *image, BOOL isDone))completion
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"temp.mp4"];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (urlData) {
        [urlData writeToFile:filePath atomically:YES];
    }
    AVURLAsset* movie = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray* tracks = [movie tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* track = [tracks lastObject];
    
    NSError* error = nil;
    AVAssetReader* areader = [[AVAssetReader alloc] initWithAsset:movie error:&error];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                             nil];
    if (!track) {
        return;
    }
    AVAssetReaderTrackOutput* rout = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:options];
    [areader addOutput:rout];
    
    [areader startReading];
    NSUInteger frameIndex = 0;
    while ([areader status] == AVAssetReaderStatusReading) {
        CMSampleBufferRef sbuff = [rout copyNextSampleBuffer];
        
        if (sbuff) {
            if ((frameIndex++)%6 == 0) {
                UIImage *image = [self imageFromSampleBuffer:sbuff];
                image = [image vImageScaledImageWithSize:size];
                NSData *imgData= UIImageJPEGRepresentation(image, compression);
                image = [UIImage imageWithData:imgData];
                completion(image, NO);
            }
            CFRelease(sbuff);
        }
    }
    completion(nil, YES);
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    return (image);
}

@end
