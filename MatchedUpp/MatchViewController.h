//
//  MatchViewController.h
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import <UIKit/UIKit.h>

//protocolo para ir a homeVC y luego directo a matchesVC
@protocol MatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MatchViewController : UIViewController

@property (weak, nonatomic) id <MatchViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (strong, nonatomic) IBOutlet UIButton *viewChatsButton;
@property (strong, nonatomic) IBOutlet UIButton *keepSearchingButton;

@property (strong, nonatomic) UIImage *matchImage;

@end
