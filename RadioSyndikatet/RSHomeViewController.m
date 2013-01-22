//
//  RSHomeViewController.m
//  RadioSyndikatet
//
//  Created by Jacob Hauberg Hansen on 1/22/13.
//  Copyright (c) 2013 Jacob Hauberg Hansen. All rights reserved.
//

#import "RSHomeViewController.h"

#import <AVFoundation/AVFoundation.h>

static NSString* const kAVPlayerStatusKey = @"status";
static NSTimeInterval const kAVPlayerBufferingDuration = 5.0; // in seconds

@interface RSHomeViewController ()

@property (nonatomic, strong) AVPlayer* player;

- (void) refresh;

@end

@implementation RSHomeViewController

- (id) init {
    return [self initWithNibName: @"RSHomeViewController"
                          bundle: nil];
}

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil {
    if ((self = [super initWithNibName: nibNameOrNil
                                bundle: nibBundleOrNil])) {
        
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.playToggleButton.enabled = NO;
    self.playToggleButton.selected = NO;
    self.playToggleButton.alpha = 0.5f;
    
    self.player = [AVPlayer playerWithURL:
                   [NSURL URLWithString: kRSFeedUrl]];
    
    [self.player addObserver: self
                  forKeyPath: kAVPlayerStatusKey
                     options: 0
                     context: nil];
    
    [self refresh];
}

- (void) viewDidUnload {
    [super viewDidUnload];
    
    NSError* sessionError = nil;
    
    [[AVAudioSession sharedInstance] setActive: NO error: &sessionError];
    
    if (sessionError) {
        NSLog(@"%@", sessionError);
    }
    
    [self.player removeObserver: self
                     forKeyPath: kAVPlayerStatusKey];
}

- (void) refresh {
    self.nextOrCurrentProgramLabel.hidden = YES;
}

- (IBAction) playWasToggled: (id) sender {
    self.playToggleButton.selected = !self.playToggleButton.selected;
    
    if (self.playToggleButton.selected) {
        [self play];
    } else {
        [self stop];
    }
}

- (void) play {
    if (self.player) {
        [self stop];
    }
    
    [self.bufferingActivityIndicator startAnimating];
    
    [self.player play];
    
    [self determinePlayingState];
}

- (void) stop {
    if (!self.player) {
        return;
    }
    
    [self.player pause];
}

- (BOOL) isReadyToPlay {
    if (!self.player) {
        return NO;
    }
    
    AVPlayerItem* playerItem = [self.player currentItem];
    
    if (playerItem) {
        CMTimeRange timeRange = kCMTimeRangeZero;
        
        [[[playerItem loadedTimeRanges] objectAtIndex: 0]
         getValue: &timeRange];
        
        if (!CMTIMERANGE_IS_EMPTY(timeRange)) {
            CMTime duration = timeRange.duration;

            float secondsBuffered = (float)duration.value / (float)duration.timescale;

            if (secondsBuffered > kAVPlayerBufferingDuration) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void) determinePlayingState {
    if ([self isReadyToPlay]) {
        [self.bufferingActivityIndicator stopAnimating];
    } else {
        // keep checking at small intervals to determine when the stream has (probably) started playing
        [self performSelector: @selector(determinePlayingState)
                   withObject: nil
                   afterDelay: 0.1];
    }
}

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context {
    if (!self.player) {
        return;
    }
    
    switch (self.player.status) {
        case AVPlayerItemStatusReadyToPlay: {
            self.playToggleButton.enabled = YES;
            self.playToggleButton.alpha = 1.0f;
        } break;
            
        case AVPlayerItemStatusFailed: {
            self.playToggleButton.enabled = NO;
            self.playToggleButton.alpha = 0.1f;
        } break;
            
        default:
            break;
    }
}

@end
