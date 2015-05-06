//
//  VGConverter.h
//  FitCoach
//
//  Created by Jeremy Templier on 4/28/15.
//  Copyright (c) 2015 Jeremy Templier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VGConverter : NSObject

+ (instancetype)converter;

- (void)gifFromVideoAtURL:(NSURL *)url size:(CGSize)size qualityCompression:(CGFloat)compression completion:(void (^)(NSURL* fileURL , NSError *error))completion;
- (void)imagesForVideoAtURL:(NSURL *)url size:(CGSize)size qualityCompression:(CGFloat)compression completion:(void (^)(UIImage *image, BOOL isDone))completion;
@end
