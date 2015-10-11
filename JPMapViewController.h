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


@interface JPMapViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
//    IBOutlet MKMapView *mapView;
    CLLocationManager *clmgr;
    CLLocationCoordinate2D curPos;

    
    UILabel *titleLabel;
    UILabel *titleBudgetLabel;
    UILabel *titleRangeLabel;
    
    IBOutlet UISearchBar *searchBar;
    IBOutlet UINavigationBar *navBar;

    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultController;
    
    //budget
    int totalBudget;
    
    
    //polyline drawing
    MKPlacemark *thePlacemark;
    MKRoute *theRoute;
    MKRoute *routeData;
    
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
    
    
    //date picker
    UIDatePicker   *datePicker;

    MKPolylineRenderer  *routeLineRenderer;//이거 선그리는거 변경할라햇는데 안되서 걍 냅둔거

}
@property (nonatomic, assign) int totalBudget;
@property (nonatomic, strong) NSDate *totalStartDate;
@property (nonatomic, strong) NSDate *totalFinishDate;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *pins; //include mkplacemark
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MapRecord *mapRecord;


@end
