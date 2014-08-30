//
//  ChatRecord.h
//  TravelBudd
//
//  Created by MC on 2014. 8. 29..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatRecord : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * fromWhere;
@property (nonatomic, retain) NSString * fromWho;
@property (nonatomic, retain) NSString * timeStamp;

@end
