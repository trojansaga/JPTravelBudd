//
//  JPPinInfoView.h
//  TravelBudd
//
//  Created by MC on 2014. 10. 5..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPPinInfoView : UIView

@property (nonatomic, strong) IBOutlet UITextField *textFieldForTitle;
@property (nonatomic, strong) IBOutlet UITextField *textFieldForBudget;
@property (nonatomic, strong) IBOutlet UITextField *textFieldForOrder;
@property (nonatomic, strong) IBOutlet UITextField *textFieldForDesc;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

- (void) showLog;
@end
