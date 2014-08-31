//
//  JPChatContentCellTableViewCell.h
//  TravelBudd
//
//  Created by MC on 2014. 8. 30..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPChatContentCellTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITextView *chatContents;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel; 


@end
