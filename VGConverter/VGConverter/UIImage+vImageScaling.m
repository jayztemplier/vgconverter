//
//  UIImage+vImageScaling.m
//  UIImage+vImageScaling
//
//  Created by Matt Donnelly on 03/07/2013.
//  Copyright (c) 2013 Matt Donnelly. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <UIKit/UIKit.h>

@implementation UIImage (vImageScaling)

- (UIImage *)vImageScaledImageWithSize:(CGSize)destSize {
    UIImage *destImage = nil;
    
    // Convert UIImage to array of bytes in ARGB8888 pixel format
    CGImageRef sourceRef = [self CGImage];
    NSUInteger sourceWidth = CGImageGetWidth(sourceRef);
    NSUInteger sourceHeight = CGImageGetHeight(sourceRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *sourceData = (unsigned char*)calloc(sourceHeight * sourceWidth * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger sourceBytesPerRow = bytesPerPixel * sourceWidth;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(sourceData, sourceWidth, sourceHeight,
                                                 bitsPerComponent, sourceBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, sourceWidth, sourceHeight), sourceRef);
    CGContextRelease(context);

    NSUInteger destWidth = (NSUInteger)destSize.width;
    NSUInteger destHeight = (NSUInteger)destSize.height;
    NSUInteger destBytesPerRow = bytesPerPixel * destWidth;
    unsigned char *destData = (unsigned char*)calloc(destHeight * destWidth * 4, sizeof(unsigned char));
    
    // Create vImage_Buffers for both arrays
    vImage_Buffer src = {
        .data = sourceData,
        .height = sourceHeight,
        .width = sourceWidth,
        .rowBytes = sourceBytesPerRow
    };

    vImage_Buffer dest = {
        .data = destData,
        .height = destHeight,
        .width = destWidth,
        .rowBytes = destBytesPerRow
    };
    
    // Resize image
    vImage_Error err = vImageScale_ARGB8888(&src, &dest, NULL, kvImageHighQualityResampling);

    free(sourceData);
    
    // Create UIImage from resized image data
    CGContextRef destContext = CGBitmapContextCreate(destData, destWidth, destHeight,
                                                     bitsPerComponent, destBytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    CGImageRef destRef = CGBitmapContextCreateImage(destContext);

    destImage = [UIImage imageWithCGImage:destRef];

    CGImageRelease(destRef);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(destContext);

    free(destData);
    
    // Error handling
    if (err != kvImageNoError) {
        NSString *errorReason = [NSString stringWithFormat:@"vImageScale returned error code %zd", err];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self, @"sourceImage",
                                   [NSValue valueWithCGSize:destSize], @"destSize",
                                   nil];

        NSException *exception = [NSException exceptionWithName:@"HighQualityImageScalingFailureException" reason:errorReason userInfo:errorInfo];
       
        @throw exception;
    }
    
    return destImage;
}

- (UIImage *)vImageScaledImageWithSize:(CGSize)destSize contentMode:(UIViewContentMode)contentMode {
    CGFloat horizontalRatio = destSize.width / self.size.width;
    CGFloat verticalRatio = destSize.height / self.size.height;
    CGFloat ratio;

    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;

        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;

        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }

    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);

    return [self vImageScaledImageWithSize:newSize];
}

@end
