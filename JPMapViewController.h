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
#import "JPMapAnnotation.h"


@interface JPMapViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
//    IBOutlet MKMapView *mapView;
    CLLocationManager *clmgr;
    CLLocationCoordinate2D curPos;
    
    IBOutlet UISearchBar *searchBar;
    IBOutlet UINavigationBar *navBar;

    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultController;
    
    //polyline drawing
    MKPlacemark *thePlacemark;
    MKRoute *theRoute;
//    MKPlacemark *source;
//    MKPlacemark *dest;
    MKRoute *routeData;
    
    UILabel *titleLabel;
    
    
    //each pin data
    JPMapAnnotation         *pinAnnotation;
    IBOutlet UIView         *pinSaveView;
    IBOutlet UITextField    *pinTextFieldForTitle;
    IBOutlet UITextField    *pinTextFieldForOrder;
    IBOutlet UITextField    *pinTextFieldForBudget;
    IBOutlet UITextField    *pinTextFieldForDescription;
    IBOutlet UILabel        *pinStartDateLabel;
    IBOutlet UILabel        *pinFinishDateLabel;
    IBOutlet UIButton       *deleteButton;
    
    double                  pinLongitude;
    double                  pinLatitude;
    int                     numberOfPins;
    

}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *pins; //include mkplacemark
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MapRecord *mapRecord;


@end
