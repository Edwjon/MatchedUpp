//
//  MatchViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "MatchViewController.h"

@interface MatchViewController ()

@end

@implementation MatchViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0){
            
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                self.currentUserImageView.image = [UIImage imageWithData:data];
                self.matchedUserImageView.image = self.matchImage;
            }];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)viewChatsButtonPressed:(UIButton *)sender
{
    [self.delegate presentMatchesViewController];
    
}

- (IBAction)keepSearchingButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
