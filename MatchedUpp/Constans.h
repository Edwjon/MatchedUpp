//
//  Constans.h
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/11/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constans : NSObject

#pragma mark - UserClass

extern NSString *const kCCUserProfileKey;
extern NSString *const kCCUserProfileNameKey;
extern NSString *const kCCUserProfileFirstNameKey;
extern NSString *const kCCUserProfileLocationKey;
extern NSString *const kCCUserProfileGenderKey;
extern NSString *const kCCUserProfileBirthdayKey;
extern NSString *const kCCUserProfileInterestedInKey;
extern NSString *const kCCUserProfilePictureURL;
extern NSString *const kCCUserProfileRelationshipStatusKey;
extern NSString *const kCCUserProfileAgeKey;

#pragma mark - PhotoClass

extern NSString *const kCCPhotoClassKey;
extern NSString *const kCCPhotoUserKey;
extern NSString *const kCCPhotoPictureKey;

#pragma mark - Settings

extern NSString *const kCCMenEnabledKey;
extern NSString *const kCCWomenEnabledKey;
extern NSString *const kCCSingleEnabledKey;
extern NSString *const kCCAgeMaxKey;


@end
