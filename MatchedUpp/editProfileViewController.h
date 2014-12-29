//
//  editProfileViewController.h
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface editProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;

- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender;


@end
