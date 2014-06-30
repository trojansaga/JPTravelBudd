//
//  PinRecord.h
//  TravelBudd
//
//  Created by MC on 2014. 6. 11..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MapRecord;

@interface PinRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * p_Budget;
@property (nonatomic, retain) NSString * p_Description;
@property (nonatomic, retain) NSNumber * p_Latitude;
@property (nonatomic, retain) NSNumber * p_Longitude;
@property (nonatomic, retain) NSDecimalNumber * p_Order;
@property (nonatomic, retain) NSDate * p_StartDate;
@property (nonatomic, retain) NSString * p_Title;
@property (nonatomic, retain) NSDate * p_FinishDate;
@property (nonatomic, retain) MapRecord *map;

@end
