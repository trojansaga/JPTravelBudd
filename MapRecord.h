//
//  MapRecord.h
//  TravelBudd
//
//  Created by MC on 2014. 9. 30..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PinRecord;

@interface MapRecord : NSManagedObject

@property (nonatomic, retain) NSDate * m_FinishDate;
@property (nonatomic, retain) NSData * m_Image;
@property (nonatomic, retain) NSString * m_MapTitle;
@property (nonatomic, retain) NSString * m_Owner;
@property (nonatomic, retain) NSNumber * m_SavedLatitude;
@property (nonatomic, retain) NSNumber * m_SavedLatitudeDelta;
@property (nonatomic, retain) NSNumber * m_SavedLongitude;
@property (nonatomic, retain) NSNumber * m_SavedLongitudeDelta;
@property (nonatomic, retain) NSDate * m_StartDate;
@property (nonatomic, retain) NSNumber * m_TotalBudget;
@property (nonatomic, retain) NSNumber * m_Mid;
@property (nonatomic, retain) NSSet *pins;
@end

@interface MapRecord (CoreDataGeneratedAccessors)

- (void)addPinsObject:(PinRecord *)value;
- (void)removePinsObject:(PinRecord *)value;
- (void)addPins:(NSSet *)values;
- (void)removePins:(NSSet *)values;

@end
