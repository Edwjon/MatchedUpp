//
//  SettingsViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults]integerForKey:kCCAgeMaxKey];
    self.menSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kCCMenEnabledKey];
    self.womenSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kCCWomenEnabledKey];
    self.singlesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kCCSingleEnabledKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singlesSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
}



- (IBAction)logoutButtonPressed:(UIButton *)sender
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)editProfileButtonPressed:(UIButton *)sender
{
    
}

-(void)valueChanged:(id)sender
{
    if (sender == self.ageSlider){
        
        [[NSUserDefaults standardUserDefaults]setInteger:(int)self.ageSlider.value forKey:kCCAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    }
    
    else if (sender == self.menSwitch){
        
        [[NSUserDefaults standardUserDefaults]setBool:self.menSwitch.isOn forKey:kCCMenEnabledKey];
    }
    
    else if (sender == self.womenSwitch){
        
        [[NSUserDefaults standardUserDefaults]setBool:self.womenSwitch.isOn forKey:kCCWomenEnabledKey];
    }
    
    else if (sender == self.singlesSwitch){
        
        [[NSUserDefaults standardUserDefaults]setBool:self.singlesSwitch.isOn forKey:kCCSingleEnabledKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}













@end
