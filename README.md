# VGConverter - Video to Gif in Objective-C

VGConverter is a library that allows you to convert a video in a Gif file. You can also get access to a set of frames as UIImages of a video.


### Installation
Copy the VGConverter into your project :) That's it.

### Dependencies
This library is using UIImage+vImageScaling, written by Matt Donnelly: https://gist.github.com/mattdonnelly/5924492

### How to use it

Generate a gif file out of a video URL:
```objective-c
[[VGConverter converter] gifFromVideoAtURL:[NSURL URLWithString:VIDEO_URL] size:self.gifImageView.bounds.size qualityCompression:1.0  completion:^(NSURL *fileURL, NSError *error) {
    NSLog(@"GIF File path: %@", [fileURL absoluteString]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gif generated" message:@"Check out the logs to get the path of the gif file."
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}];
```

Get the images of a video:
```objective-c
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
```

### License
VGConverter is released under the MIT license. See LICENSE for details.
