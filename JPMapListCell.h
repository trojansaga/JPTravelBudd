//
//  JPMapListCell.h
//  TravelBudd
//
//  Created by MC on 2014. 8. 25..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPMapListCell : UITableViewCell {
}

@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *budgetLabel;
@property (nonatomic,strong) IBOutlet UILabel *fromLabel;
@property (nonatomic,strong) IBOutlet UILabel *toLabel;
@property (nonatomic,strong) IBOutlet UIImageView *imgView;

@end
