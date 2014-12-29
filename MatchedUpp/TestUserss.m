//
//  TestUserss.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 18/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "TestUserss.h"

@implementation TestUserss


+ (void)saveTestUsersToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"edwjon";
    newUser.password = @"password2";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error){
            
            NSDictionary *profile = @{@"age" : @28, @"birthday" : @"11/22/1985", @"firstName" : @"Jonathan", @"gender" : @"male", @"location" : @"Caracas, Venezuela", @"name" : @"Jonathan Pizzurro"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIImage *profileImage = [UIImage imageNamed:@"twitter.png"];
                NSLog(@"%@", profileImage);
                NSData *data = UIImageJPEGRepresentation(profileImage, 0.8);
                PFFile *photoFile = [PFFile fileWithData:data];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded){
                        PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
                        [photo setObject:newUser forKey:kCCPhotoUserKey];
                        [photo setObject:photoFile forKey:kCCPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"photo saved succesfully");
                        }];
                    }
                }];
            }];
        }
    }];
}



@end
