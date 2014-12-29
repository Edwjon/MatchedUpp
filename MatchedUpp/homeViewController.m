//
//  homeViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 16/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "homeViewController.h"
#import "TestUserss.h"
#import "ProfileViewController.h"
#import "MatchViewController.h"


@interface homeViewController () <MatchViewControllerDelegate>

@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) int currentPhotoIndex;
@property (strong, nonatomic) PFObject *photo;

@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;
@property (strong, nonatomic) NSMutableArray *activities;

@end

@implementation homeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    //Para el otro usuario
    [query whereKey:kCCPhotoUserKey notEqualTo:[PFUser currentUser]];
    
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error){
              self.photos = objects;
              [self queryForCurrentPhotoIndex];
        }
        else{
            NSLog(@"%@", error);
        }
    }];
    
}

#pragma mark - prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]){
        
        ProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
    }
    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"]){
        
        MatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchImage = self.profilePictureImageView.image;
        matchVC.delegate = self;
    }
}


#pragma mark - IBActions

- (IBAction)chatButtonPressed:(UIBarButtonItem *)sender
{
    
}

- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender
{
    
}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self checkLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)dislikeButtonPressed:(id)sender
{
    [self checkDislike];
}


#pragma mark - HelperMethods

//para obtener la imagen y poner... self.profilePictureImageView.image = image; (tambien para poner la infoa las labels(implementado el metodo updateView)) y los likes y dislikes
-(void)queryForCurrentPhotoIndex
{
    //Para la foto y lainformacion de las labels
    if ([self.photos count] > 0){
        
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[@"image"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error){
                UIImage *image = [UIImage imageWithData:data];
                self.profilePictureImageView.image = image;
                [self updateView];
            }
            
            else NSLog(@"%@", error);
        }];
        
        //Para likes y dislikes (la logica)
        PFQuery *queryForLike = [PFQuery queryWithClassName:@"Activity"];
        [queryForLike whereKey:@"type" equalTo:@"like"];
        [queryForLike whereKey:@"photo" equalTo:self.photo];
        [queryForLike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:@"Activity"];
        [queryForDislike whereKey:@"type" equalTo:@"dislike"];
        [queryForDislike whereKey:@"photo" equalTo:self.photo];
        [queryForDislike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *queryForLikeAndDislike = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [queryForLikeAndDislike findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error){
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0){
                    
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else{
                    
                    PFObject *activity = self.activities[0];
                    
                    if ([activity [@"type"]isEqualToString:@"like"]){
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity [@"type"] isEqualToString:@"dislike"]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else{
                        //Some other action
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

//para ponerle la info a las labels
-(void)updateView
{
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"firstName"];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[@"user"][@"profile"][@"age"]];
    self.tagLineLabel.text = self.photo[@"user"][@"tagLine"];
    
}

-(void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 < self.photos.count){
        
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No more users to view" message:@"Check back later for more people!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    [likeActivity setObject:@"like" forKey:@"type"];
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [likeActivity setObject:self.photo forKey:@"photo"];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self chekForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

-(void)saveDislike
{
    
    PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
    [dislikeActivity setObject:@"dislike" forKey:@"type"];
    [dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [dislikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    [dislikeActivity setObject:self.photo forKey:@"photo"];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}


-(void)checkLike
{
    if (self.isLikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    
    else{
        [self saveLike];
    }
}

-(void)checkDislike
{
    if (self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    
    else{
        [self saveDislike];
    }
}

-(void)chekForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:self.photo[kCCPhotoUserKey]];
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"like"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] > 0){
            [self createChatRoom];
        }
    }];
}

-(void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kCCPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kCCPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] == 0){
            PFObject *chatRoom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatRoom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatRoom setObject:self.photo[kCCPhotoUserKey] forKey:@"user2"];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
        }
    }];
}


#pragma mark - MatchViewController Delegate

-(void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}




@end
