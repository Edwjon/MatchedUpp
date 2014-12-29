//
//  LoginViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 19/11/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *avtivityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.avtivityIndicator.hidden = YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"toHome" sender:self];
    }
}



- (IBAction)loginButton:(UIButton *)sender
{
    self.avtivityIndicator.hidden = NO;
    [self.avtivityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        [self.avtivityIndicator stopAnimating];
        self.avtivityIndicator.hidden = YES;
        
        if (!user){
            if (!error){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else{
                UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"Log in Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alerta show];
            }
        }
        else{
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"toHome" sender:self];
            
        }
    }];
}

#pragma mark - MetodosAyuda

//Para obtener la info del usuario en facebook (nombre, cumple, etc)
-(void)updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            
            if ([pictureURL absoluteString]){
                userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
            }
            if (userDictionary[@"name"]){
                userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]){
                userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]){
                userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]){
                userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]){
                userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds / 31536000;
                
                userProfile[kCCUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"relationship_status"]){
                userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            if (userDictionary[@"interested_in"]){
                userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            
            [[PFUser currentUser]setObject:userProfile forKey:kCCUserProfileKey];
            
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        }
        else {
            NSLog(@"Error in FB request %@", error);
        }
    }];
}

//Para obtener la imagen de ususario de Facebook y subirla a Parse

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if (!imageData){
        NSLog(@"imageData was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kCCPhotoUserKey];
            [photo setObject:photoFile forKey:kCCPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"photo saved succesfully");
            }];
        }
    }];
}

//Para obtener la imagen en la app y descargarla (en la app)
-(void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0){
            
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to download the picture");
            }
            
        }
    }];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}


@end
