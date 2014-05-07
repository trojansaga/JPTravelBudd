//
//  JPChatViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate> {
    IBOutlet UITableView *chatRoomListTableView;
    int numOfChatRooms;
    NSArray *chatRoomListArray;
    
    
}

-(void)sendData:(NSArray *)objects :(NSArray *)keys :(NSString *)to;

@end
