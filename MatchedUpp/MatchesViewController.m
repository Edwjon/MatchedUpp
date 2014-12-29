//
//  MatchesViewController.m
//  MatchedUpp
//
//  Created by Edward Pizzurro Fortun on 21/12/14.
//  Copyright (c) 2014 Edwjon. All rights reserved.
//

#import "MatchesViewController.h"
#import "ChattViewController.h"

@interface MatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *avaliableChatRooms;

@end

@implementation MatchesViewController

-(NSMutableArray *)avaliableChatRooms
{
    if (!_avaliableChatRooms){
        _avaliableChatRooms = [[NSMutableArray alloc]init];
    }
    return _avaliableChatRooms;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChattViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    chatVC.chatRoom = [self.avaliableChatRooms objectAtIndex:indexPath.row];
}


#pragma mark - Helper Methods

-(void)updateAvaliableChatRooms
{
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:@"chat"];
    [queryCombined includeKey:@"user1"];
    [queryCombined includeKey:@"user2"];
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error){
            [self.avaliableChatRooms removeAllObjects];
            self.avaliableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.avaliableChatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *hola = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hola];
    
    PFObject *chatRoom = self.avaliableChatRooms[indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[@"user1"];
    
    if ([testUser1.objectId isEqual:currentUser.objectId]){
        likedUser = [chatRoom objectForKey:@"user2"];
    }
    else{
        likedUser = [chatRoom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    
    //Para la imagen en la celda
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"user" equalTo:likedUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] > 0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"matchesToChat" sender:indexPath];
}









@end
