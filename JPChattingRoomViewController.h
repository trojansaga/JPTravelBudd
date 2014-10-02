//
//  JPChattingRoomViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JPAppDelegate.h"

@class MapRecord;

@interface JPChattingRoomViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,  NSURLConnectionDataDelegate> {
    IBOutlet UITextField *textFieldForMessage;
    IBOutlet UITableView *chattingTableView;
    IBOutlet UIButton *roomExitButton;

    NSMutableArray *chattingContents;
    NSString *nickName;
    JPAppDelegate *appDelegate;
    
    NSString *conferenceDomain;
    NSString *domain;

    //temp
    NSString *sendedString;
    
    
}
@property (nonatomic, strong) NSString *chatRoomTitle;
@property (nonatomic, strong) NSArray *joinedMemberListArray;
@property (nonatomic, strong) NSString *cr_id_room;
@property (nonatomic, strong) NSString *crm_id;
@property (nonatomic, strong) NSString *m_id;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSManagedObjectContext *mob;

@property (nonatomic, strong) IBOutlet UIView *viewForMoreButtons;
@property (nonatomic, strong) IBOutlet MKMapView *roomMapView;
//@property (nonatomic, assign) NSInteger countOfChattingContents;

@property (nonatomic, strong) MapRecord *mapData;


@end
