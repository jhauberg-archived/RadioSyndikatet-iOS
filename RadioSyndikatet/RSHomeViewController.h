//
//  RSHomeViewController.h
//  RadioSyndikatet
//
//  Created by Jacob Hauberg Hansen on 1/22/13.
//  Copyright (c) 2013 Jacob Hauberg Hansen. All rights reserved.
//

@interface RSHomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel* nextOrCurrentProgramLabel;
@property (nonatomic, weak) IBOutlet UIButton* playToggleButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* bufferingActivityIndicator;

- (IBAction) playWasToggled: (id) sender;

- (void) play;
- (void) stop;

@end
