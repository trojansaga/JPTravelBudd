//
//  JPChatViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPChattingRoomViewController.h"

#import "JPAppDelegate.h"

@interface JPChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate> {
    IBOutlet UITableView *chatRoomListTableView;
    int numOfChatRooms;
    NSArray *chatRoomListArray;

    JPAppDelegate *appDelegate;

    
    UIActivityIndicatorView *indicator;
    JPChattingRoomViewController *chattingRoomViewController;
    IBOutlet UINavigationBar *navBar;
    
}
//@property (nonatomic, strong) JPConnectionDelegateObject *jpConnectionDelegate;


//-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr delegate:(id) delegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end
