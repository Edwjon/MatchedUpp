//
//  ProfileViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFFile *pictureFile = self.photo[kCCPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    
    PFUser *user = self.photo[kCCPhotoUserKey];
    self.locationLabel.text = user[kCCUserProfileKey][kCCUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kCCUserProfileKey][kCCUserProfileAgeKey]];
    self.statusLabel.text = user[kCCUserProfileKey][kCCUserProfileRelationshipStatusKey];
    self.tagLineLabel.text = user[@"tagLine"];
    
}



@end
