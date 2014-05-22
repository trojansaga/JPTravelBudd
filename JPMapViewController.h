//
//  JPMapViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface JPMapViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
    CLLocationManager *clmgr;
    CLLocationCoordinate2D curPos;
    IBOutlet UISearchBar *searchBar;
    
    IBOutlet UINavigationBar *navBar;
    IBOutlet UILabel <MKAnnotation> *annoLabel;
}



@end
