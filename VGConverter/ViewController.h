//
//  ViewController.h
//  VGConverter
//
//  Created by Jeremy Templier on 5/5/15.
//  Copyright (c) 2015 Jeremy Templier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *layer;
@end

