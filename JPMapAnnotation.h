//
//  JPMapAnnotation.h
//  TravelBudd
//
//  Created by MC on 2014. 8. 2..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JPMapAnnotation : MKPointAnnotation <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;

//@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * budget;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * finishDate;
@end
