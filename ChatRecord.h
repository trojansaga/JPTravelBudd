//
//  ChatRecord.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 14..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatRecord : NSManagedObject

@property (nonatomic, retain) NSString * body; // text
@property (nonatomic, retain) NSDate * timeStamp; // sorting factor
@property (nonatomic, retain) NSString * fromWho; // sender Name
@property (nonatomic, retain) NSString * fromWhere; // group Name

@end
