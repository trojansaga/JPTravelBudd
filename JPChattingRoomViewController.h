//
//  JPChattingRoomViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPChattingRoomViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,  NSURLConnectionDataDelegate > {
    IBOutlet UITextField *textFieldForMessage;
    IBOutlet UITableView *chattingTableView;


    
}

@property (nonatomic, strong) NSArray *joinedMemberListArray;
@property (nonatomic, assign) int cr_id_room;

@end
