//
//  JPMakeChatRoomViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPMakeChatRoomViewController : UIViewController {
    IBOutlet UITextField *textFieldForRoomName;
    IBOutlet UITextField *textFieldForRoomMaxNum;
    IBOutlet UITextField *textFieldForRoomDesc;
    IBOutlet UISwitch *switchForSecret;
    IBOutlet UITextView *textViewForRoomDesc;
}

@end
