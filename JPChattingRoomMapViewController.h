//
//  JPChattingRoomMapViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 10. 1..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapRecord;
@interface JPChattingRoomMapViewController : UIViewController {
//    IBOutlet UILabel *labelForTitle;
//    IBOutlet UILabel *labelForTotalBudget;
//    IBOutlet UILabel *labelForRange;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *mob;
@property (nonatomic, strong) MapRecord *mapData;
@property (nonatomic, strong) IBOutlet UILabel *labelForTitle;

- (void)refreshMap;
- (void) addPins;

@end
