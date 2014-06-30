//
//  JPMapViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapRecord.h"


@interface JPMapViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
//    IBOutlet MKMapView *mapView;
    CLLocationManager *clmgr;
    CLLocationCoordinate2D curPos;
    IBOutlet UISearchBar *searchBar;
    
    IBOutlet UINavigationBar *navBar;
    IBOutlet UILabel <MKAnnotation> *annoLabel;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultController;
    
    MKPlacemark *thePlacemark;
    MKRoute *theRoute;
    MKPlacemark *source;
    MKPlacemark *dest;
    MKRoute *data;
    
    
    IBOutlet UIView         *pinSaveView;
    IBOutlet UITextField    *pinTextFieldForTitle;
    IBOutlet UITextField    *pinTextFieldForOrder;
    IBOutlet UITextField    *pinTextFieldForBudget;
    double                  pinLongitude;
    double                  pinLatitude;
    

}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *pins; //include mkplacemark
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MapRecord *mapRecord;


@end
