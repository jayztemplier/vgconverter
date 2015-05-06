//
//  ViewController.m
//  VGConverter
//
//  Created by Jeremy Templier on 5/5/15.
//  Copyright (c) 2015 Jeremy Templier. All rights reserved.
//

#import "ViewController.h"
#import "VGConverter.h"

#define VIDEO_URL @"https://distilleryvesper11-7-a.akamaihd.net/abc661c6808c11e3b65e12a560366f47_101.mp4"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVideo:VIDEO_URL inView:_videoContainer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)convertPressed:(id)sender {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [[VGConverter converter] imagesForVideoAtURL:[NSURL URLWithString:VIDEO_URL] size:self.gifImageView.bounds.size qualityCompression:1.0 completion:^(UIImage *image, BOOL isDone) {
        if (image) {
            [images addObject:image];
        }
        if (isDone) {
            [_gifImageView setAnimationImages:images];
            [_gifImageView setAnimationDuration:2.0];
            [_gifImageView startAnimating];
        }
    }];
    
    [[VGConverter converter] gifFromVideoAtURL:[NSURL URLWithString:VIDEO_URL] size:self.gifImageView.bounds.size qualityCompression:1.0  completion:^(NSURL *fileURL, NSError *error) {
        NSLog(@"GIF File path: %@", [fileURL absoluteString]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gif generated" message:@"Check out the logs to get the path of the gif file."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)setupVideo:(NSString *)videoURLString inView:(UIView *)view{
    if (!self.avPlayer) {
        NSURL *fileURL = [NSURL URLWithString:videoURLString];
        self.avPlayer = [AVPlayer playerWithURL:fileURL];
        self.avPlayer.muted = YES;
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.avPlayer currentItem]];
        
        
        _layer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    }
    _layer.frame = view.bounds;
    [view.layer addSublayer:_layer];
    [self.avPlayer play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

@end
