//
//  JPMakeChatRoomViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapRecord;

@interface JPMakeChatRoomViewController : UIViewController <NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITextField *textFieldForRoomName;
    IBOutlet UITextField *textFieldForRoomMaxNum;
    IBOutlet UITextField *textFieldForRoomDesc;
    IBOutlet UISwitch *switchForSecret;
    IBOutlet UITextView *textViewForRoomDesc;
    IBOutlet UIView *mapSelectionView;
    IBOutlet UITableView *mapListTableView;
    IBOutlet UIImageView *mapImageView;
    
    IBOutlet UIView *grView;

    NSArray *mapListArray;
    MapRecord *selectedMapRecord;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
