//
//  JPMapAnnotation.m
//  TravelBudd
//
//  Created by MC on 2014. 8. 2..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMapAnnotation.h"

@implementation JPMapAnnotation

- (CLLocationCoordinate2D)coordinate
{
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    [super setCoordinate:coordinate];
    
}




@end
