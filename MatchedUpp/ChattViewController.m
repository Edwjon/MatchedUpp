//
//  ChattViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "ChattViewController.h"

@interface ChattViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSTimer *chatTimers;
@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChattViewController

-(NSMutableArray *)chats
{
    if (!_chats){
        _chats = [[NSMutableArray alloc]init];
    }
    return _chats;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance]setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[@"user2"];
    }
    else{
        self.withUser = self.chatRoom[@"user1"];
    }
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatTimers = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.chatTimers invalidate];
    self.chatTimers = nil;
}

#pragma mark - TableView DataSource REQUIRED


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

-(void)didSendText:(NSString *)text
{
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    [chat setObject:self.chatRoom forKey:@"chatroom"];
    [chat setObject:self.currentUser forKey:@"fromUser"];
    [chat setObject:self.withUser forKey:@"toUser"];
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [self.chats addObject:chat];
        [JSMessageSoundEffect playMessageSentSound];
        [self.tableView reloadData];
        [self finishSend];
        [self scrollToBottomAnimated:YES];
        
    }];
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return JSBubbleMessageTypeOutgoing;
    }
    else{
        return JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else{
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}



-(JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

-(JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPTIONAL

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing){
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - MessagesView Data Source REQUIRED

-(NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[@"text"];
    return message;
    
}

-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - HelperMethods

-(void)checkForNewChats
{
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]){
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                
                if (self.initialLoadComplete == YES){
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
                
            }
        }
    }];
}








@end
