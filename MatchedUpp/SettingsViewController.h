//
//  SettingsViewController.h
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *menSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singlesSwitch;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;

- (IBAction)logoutButtonPressed:(UIButton *)sender;

- (IBAction)editProfileButtonPressed:(UIButton *)sender;



@end
