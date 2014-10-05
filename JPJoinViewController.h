//
//  JPJoinViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 9. 26..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapRecord.h"
#import "JPChattingRoomMapViewController.h"




@interface JPJoinViewController : UIViewController <MKMapViewDelegate> {
    
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *labelForTitle;
    IBOutlet UILabel *labelForBudget;
    IBOutlet UILabel *labelForStartDate;
    IBOutlet UILabel *labelForFinishDate;
    IBOutlet UIView *infoView;

    
    
    MKPolylineRenderer  *routeLineRenderer;
    //polyline drawing
    MKPlacemark *thePlacemark;
    MKRoute *theRoute;
    MKRoute *routeData;
    
}

@property (nonatomic, strong) JPChattingRoomMapViewController *chattingRoomViewController;
@property (nonatomic, strong) NSString *crID;
@property (nonatomic, strong) MapRecord *mapData;
@property (nonatomic, strong) NSManagedObjectContext *mob;
//@property (nonatomic, strong)

@end
