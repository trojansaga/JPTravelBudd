//
//  JPLoginViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 3..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPLoginViewController : UIViewController <NSURLConnectionDataDelegate,NSURLConnectionDelegate> {
    IBOutlet UITextField *textFieldForID;
    IBOutlet UITextField *textFieldForPW;
    IBOutlet UIView *joinUsView;
    IBOutlet UITextField *textFieldForJoinUsID;
    IBOutlet UITextField *textFieldForJoinUsPW;

}



@end
