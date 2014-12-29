//
//  editProfileViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "editProfileViewController.h"

@interface editProfileViewController ()

@end

@implementation editProfileViewController



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
                if (!error){
                    self.profilePictureImageView.image = [UIImage imageWithData:data];
                }
            }];
        }
    }];
    
    self.tagLineTextView.text = [[PFUser currentUser]objectForKey:@"tagLine"];
}




- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender
{
    [[PFUser currentUser]setObject:self.tagLineTextView.text forKey:@"tagLine"];
    [[PFUser currentUser]saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
    
}





@end
