//
//  ChattViewController.h
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ChattViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
