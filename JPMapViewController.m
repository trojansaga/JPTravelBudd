//
//  JPMapViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMapViewController.h"
#import "JPAppDelegate.h"
#import "MapRecord.h"
#import "PinRecord.h"
#import "JPMapAnnotation.h"


@interface JPMapViewController ()

@end

@implementation JPMapViewController

#pragma mark - Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //map view setting
    [_mapView setZoomEnabled:YES];

    clmgr = [[CLLocationManager alloc] init];
    clmgr.desiredAccuracy = kCLLocationAccuracyBest;
    clmgr.distanceFilter = kCLHeadingFilterNone;
    
    [clmgr setDelegate:self];
    [clmgr startUpdatingLocation];
    
    
    

    //이거 어차피 불러올때 세팅해줌
//    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    _managedObjectContext = [appDelegate managedObjectContext];
    
    
    
    //nav bar customization
    self.navigationItem.title = @"Map";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Save"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(saveCurrentMap)];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    
//    navBar = self.navigationController.navigationBar;
//    [self.view insertSubview:navBar atIndex:0];
    

    //싸이즈 맞게 다 알아서 조절합니다 허허허
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (self.view.bounds.size.width - self.navigationItem.leftBarButtonItem.width - self.navigationItem.rightBarButtonItem.width), self.navigationController.navigationBar.bounds.size.height)];

    //이거 안해서 자꾸 제스쳐레코그나이저 안됫엇음 짜증남. 이게 기본 세팅이 노우로 되어있어요.
    [titleLabel setUserInteractionEnabled:YES];
    titleLabel.backgroundColor = [UIColor brownColor];
    
    //TapGestureRecongnizer
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(changeTitle)];
    tg.numberOfTapsRequired = 1;
    tg.numberOfTouchesRequired = 1;
    [titleLabel addGestureRecognizer:tg];
    
    self.navigationItem.titleView = titleLabel;
//    [self.navigationItem.titleView addGestureRecognizer:tg];

    

    
    //LongPress GestureRecognizer
    UILongPressGestureRecognizer *longPressGestureRecongnizer = [[UILongPressGestureRecognizer alloc]
                                                                 initWithTarget:self
                                                                 action:@selector(longPressOnMapView:)];
    [_mapView addGestureRecognizer:longPressGestureRecongnizer];
    
    
    [pinSaveView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    [self.view addSubview:pinSaveView];
    [pinSaveView setAlpha:0];

    _pins = [[NSMutableArray alloc] init];

    //core data setting
//    _mapRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
//    NSFetchRequest *fetchReqest = [[NSFetchRequest alloc] initWithEntityName:@"MapRecord"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"m_MapTitle == %@",nil];
//    [fetchReqest setPredicate:predicate];
//    NSArray *arr = [_managedObjectContext executeFetchRequest:fetchReqest error:nil];



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_managedObjectContext rollback];
    // 세이브 안하고 뒤로 가기를 눌렀을 때만, 롤백을 하게 할라고 함.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = @"noname";
    

    // 처음 만들었을때
    if (_mapRecord == nil) {
        UIAlertView *titleSetAV = [[UIAlertView alloc]
                           initWithTitle:@"insert Title"
                           message:nil
                           delegate:self
                           cancelButtonTitle:@"cancel"
                           otherButtonTitles:@"ok", nil];
        titleSetAV.alertViewStyle = UIAlertViewStylePlainTextInput;
        [titleSetAV show];
        
        JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appDelegate managedObjectContext];

        _mapRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
        
    }
    

    
    // 존재하는 시키
    else {
        titleLabel.text = [_mapRecord m_MapTitle];
        
        numberOfPins = [_mapRecord.pins count];
        
        for (PinRecord *pin in _mapRecord.pins) {
            
            double longitude = [pin.p_Longitude doubleValue];
            double latitude = [pin.p_Latitude doubleValue];
            
            JPMapAnnotation *pinMark = [[JPMapAnnotation alloc] init];
            [pinMark setTitle:pin.p_Title];
            [pinMark setSubtitle:pin.p_Description];
            [pinMark setStartDate:pin.p_StartDate];
            [pinMark setFinishDate:pin.p_FinishDate];
            [pinMark setCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            [pinMark setBudget:pin.p_Budget];
            [pinMark setOrder:pin.p_Order];

            [_mapView addAnnotation:pinMark];
            [_pins addObject:pinMark];
          
        }
    }
}

#pragma mark - Actions



- (void) changeTitle {
    UIAlertView *titleSetAV = [[UIAlertView alloc]
                               initWithTitle:@"insert Title"
                               message:nil
                               delegate:self
                               cancelButtonTitle:@"cancel"
                               otherButtonTitles:@"ok", nil];
    titleSetAV.alertViewStyle = UIAlertViewStylePlainTextInput;
    [titleSetAV show];
    
}

- (IBAction)buttonClick: (id)sender{
    [_mapView removeOverlays:[_mapView overlays]];
    [self drawLines];
    
}





- (void) saveCurrentMap {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Saved"
                              message:@"success"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"ok", nil];
    [alertView show];

    [_mapRecord setM_MapTitle:titleLabel.text];
    
    //remove all pins
    [_mapRecord removePins:_mapRecord.pins];
    
    
    for (JPMapAnnotation* anno in _pins) {
        PinRecord *pinRecord = [NSEntityDescription insertNewObjectForEntityForName:@"PinRecord" inManagedObjectContext:_managedObjectContext];
        [pinRecord setP_Title:anno.title];
        [pinRecord setP_Description:anno.subtitle];
        [pinRecord setP_Latitude:anno.latitude];
        [pinRecord setP_Longitude:anno.longitude];
        [pinRecord setP_Order:anno.order];
        [pinRecord setP_Budget:anno.budget];
        [pinRecord setP_StartDate:anno.startDate];
        [pinRecord setP_FinishDate:anno.finishDate];
        
        [self.mapRecord addPinsObject:pinRecord];
    }

    [_managedObjectContext save:nil];
    

}



- (void) clickPinEditButton {
    
    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
}

- (void) longPressOnMapView: (UIGestureRecognizer *)gestureRecognizer {
    
    pinTextFieldForOrder.text = [NSString stringWithFormat:@"%i", numberOfPins];
    pinTextFieldForTitle.text = @"";
    pinTextFieldForDescription.text = @"";
    pinTextFieldForBudget.text = @"";
    deleteButton.hidden = YES;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];

    pinLatitude = touchMapCoordinate.latitude;
    pinLongitude = touchMapCoordinate.longitude;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
}


//현재 위치에서 찍으면 선 그려주는거
- (void) addLine:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
        [_mapView removeAnnotations:[_mapView annotations]];
        MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:touchMapCoordinate addressDictionary:nil];
        [_mapView addAnnotation:pm];
        
        
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];

        [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
        [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:pm]];
        directionsRequest.transportType = MKDirectionsTransportTypeWalking;

        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                routeData = [[response routes] lastObject];
                [_mapView addOverlay:routeData.polyline];
                NSLog(@"wow");
            }
        }];
    
}


#pragma mark - MapView Control

- (void) drawLines {
    
    // 임의적으로 기냥 새 인스턴스를 만들어서 그림만 그린다.. 문제가 있음
    //    NSLog(@"%d", [_pins count]);
    
    
    // temp sortedArray for drawing only
    NSArray *sortedArray;
    sortedArray = [_pins sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(JPMapAnnotation *)a budget];
        NSNumber *second = [(JPMapAnnotation *)b budget];
        return [first compare:second];
    }];
    
    for (int i = 0; i < [sortedArray count]-1; i++) {
        //        JPMapAnnotation *pinMark = [_pins objectAtIndex:i];
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        //        [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:i]]];
        //        [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:(i+1)]]];
        
        // 요 부분이, mkplacemark를 새로 만들어서 그림을 그려줌. 이거 나중에 문제될듯.
        // 아마 나중에 삭제하는 부분에서 문제가 발생할 것으로 예상됩니다 허허
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[[_pins objectAtIndex:i] coordinate] addressDictionary:nil];
        MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:[[_pins objectAtIndex:i+1] coordinate] addressDictionary:nil];
        [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:sourcePlacemark]];
        [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:destPlacemark]];
        
        directionsRequest.transportType = MKDirectionsTransportTypeWalking;
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                routeData = [[response routes] lastObject];
                [_mapView addOverlay:routeData.polyline];
                NSLog(@"one line is drawn.");
            }
        }];
    }
    
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated {
    MKCoordinateSpan span = MKCoordinateSpanMake(0, 360/pow(2, zoomLevel)*_mapView.frame.size.width/256);
    [_mapView setRegion:MKCoordinateRegionMake(centerCoordinate, span) animated:animated];
}

-(IBAction)curButClick:(id)sender {
    
    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
    [_mapView setCenterCoordinate:curPos animated:YES];
    [self setCenterCoordinate:curPos zoomLevel:10 animated:YES];
    
    
}

-(IBAction)move:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:btn.titleLabel.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [_mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
                
            }
        }
    }];
    
}



#pragma mark - AddPin View

- (IBAction)cancelLongPress:(id)sender {
    [pinSaveView setAlpha:0];
}

- (IBAction)deletePin:(id)sender {
//    UIButton *button = sender;
    NSLog(@"delete pin, %@", [[(UIButton *)sender titleLabel] text]);
    [_mapView removeAnnotation:pinAnnotation];

    
}

- (IBAction)clickPinSaveButton:(id)sender {
    
    if ([pinTextFieldForBudget.text isEqualToString:@""]
        //        || [pinTextFieldForDescription.text isEqualToString:@""]
        || [pinTextFieldForOrder.text isEqualToString:@""]
        || [pinTextFieldForTitle.text isEqualToString:@""]) {
        UIAlertView *titleSetAV = [[UIAlertView alloc]
                                   initWithTitle:@"Please Insert Data"
                                   message:nil
                                   delegate:self
                                   cancelButtonTitle:@"ok"
                                   otherButtonTitles:nil];
        titleSetAV.alertViewStyle = UIAlertViewStyleDefault;
        [titleSetAV show];
        return;
    }
    
    [pinSaveView setAlpha:0];
    
    
    //postpone to save pinrecord -> keep data as JPMapAnnotation only. Just
    //    PinRecord *pinRecord = [NSEntityDescription insertNewObjectForEntityForName:@"PinRecord" inManagedObjectContext:_managedObjectContext];
    //    [pinRecord setP_Title:pinTextFieldForTitle.text];
    //    [pinRecord setP_Description:pinTextFieldForDescription.text];
    //    [pinRecord setP_Order:[NSNumber numberWithInt:[pinTextFieldForOrder.text intValue]]];
    //    [pinRecord setP_Budget:[NSNumber numberWithInt:[pinTextFieldForBudget.text intValue]]];
    //
    //    [pinRecord setP_Longitude:[NSNumber numberWithDouble:pinLongitude]];
    //    [pinRecord setP_Latitude:[NSNumber numberWithDouble:pinLatitude]];
    //
    //    [pinRecord setP_StartDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    //    [pinRecord setP_FinishDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    //
    //    [_mapRecord addPinsObject:pinRecord];
    
    
    BOOL isNewPin = YES;
    
    JPMapAnnotation *pinMark;
    
    for (JPMapAnnotation* anno in _pins) {
        
        //if there is already
        if ([pinTextFieldForOrder.text isEqualToString:[NSString stringWithFormat:@"%i", [anno.order intValue]]]) {
            isNewPin = NO;
            pinMark = anno;
            [pinMark setCoordinate:CLLocationCoordinate2DMake([anno.latitude doubleValue], [anno.longitude doubleValue])];
            [pinMark setTitle:pinTextFieldForTitle.text];
            //description textscrollview로 변경? 포함하고있는 스트링이 너무 짧아서, 길게 보여주는걸 원할거같다..
            [pinMark setSubtitle:pinTextFieldForDescription.text];
            [pinMark setOrder:[NSNumber numberWithInt:[pinTextFieldForOrder.text intValue]]];
            [pinMark setBudget:[NSNumber numberWithInt:[pinTextFieldForBudget.text intValue]]];
            
            [pinMark setStartDate:[NSDate dateWithTimeIntervalSince1970:0]];
            [pinMark setFinishDate:[NSDate dateWithTimeIntervalSince1970:0]];
        }
    }
    
    
    if(isNewPin == YES)
        //add new pin
    {

        pinMark = [[JPMapAnnotation alloc] init];
        [pinMark setCoordinate:CLLocationCoordinate2DMake(pinLatitude, pinLongitude)];
        [pinMark setTitle:pinTextFieldForTitle.text];
        //description textscrollview로 변경? 포함하고있는 스트링이 너무 짧아서, 길게 보여주는걸 원할거같다..
        [pinMark setSubtitle:pinTextFieldForDescription.text];
        [pinMark setOrder:[NSNumber numberWithInt:[pinTextFieldForOrder.text intValue]]];
        [pinMark setBudget:[NSNumber numberWithInt:[pinTextFieldForBudget.text intValue]]];
        
        [pinMark setStartDate:[NSDate dateWithTimeIntervalSince1970:0]];
        [pinMark setFinishDate:[NSDate dateWithTimeIntervalSince1970:0]];
        
        [_mapView addAnnotation:pinMark];
        
        [_pins addObject:pinMark];
        numberOfPins++; // increase pin number by 1.
    }
}

#pragma mark - Overlay

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
//    MKPolylineView *polyLineView = [[MKPolylineView alloc] initWithOverlay: overlay];
//    polyLineView.strokeColor = [UIColor redColor];
//    polyLineView.lineWidth   = 5.0;
//    return polyLineView;
    return nil;
}





#pragma mark - Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *cordd = locations.lastObject;
    curPos = [cordd coordinate];
//    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
//    [mapView setCenterCoordinate:curPos];
//    [manager stopUpdatingLocation];

}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeData.polyline];

    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    
    return routeLineRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    
    if ([annotation isKindOfClass:[MKUserLocation class]]){
//        MKPinAnnotationView *userPin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"userLocationAnnotationView"];
        MKPinAnnotationView *userPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        userPin.pinColor = MKPinAnnotationColorGreen;

        return userPin;
    }
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];

        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.draggable = YES;

        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            for (CLPlacemark *placemark in placemarks) {
                NSLog(@"%@", [placemark description]);
                [_mapView setCenterCoordinate:placemark.location.coordinate animated:YES];
            }
        }
    }];
    
    [searchBar resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    if ([alertView.title isEqualToString:@"Saved"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([alertView.title isEqualToString:@"insert Title"]) {
        if (buttonIndex == 1) { // only when ok clicked
            UITextField *textFieldForTitle = [alertView textFieldAtIndex:0];
            
            //        self.navigationItem.title = textFieldForTitle.text;
            titleLabel.text = textFieldForTitle.text;
            //        self.title = textFieldForTitle.text;

        }
    }

}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    JPMapAnnotation *anno = (JPMapAnnotation *)[view annotation];
    NSLog(@"click anno, %@", [anno order]);
    NSLog(@"coordinate : (%f, %f)",anno.coordinate.latitude,anno.coordinate.longitude);
    pinAnnotation = anno;
    deleteButton.hidden = NO;


}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"click callout");
    JPMapAnnotation *annoData = view.annotation;
    pinTextFieldForTitle.text = annoData.title;
    pinTextFieldForDescription.text = annoData.subtitle;
    pinTextFieldForOrder.text = [NSString stringWithFormat:@"%i",[annoData.order intValue]];
    pinTextFieldForBudget.text = [NSString stringWithFormat:@"%i", [annoData.budget intValue]];

    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
    
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    
}

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    
//    NSString *reuseName = @"anno";
//    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseName];
//    
//    if (pin == nil) {
//        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseName];
//        pin.animatesDrop = YES;
//        pin.pinColor = MKPinAnnotationColorGreen;
//    }
//    else {
//        pin.annotation = annotation;
//    }
//    
//    return pin;
//}

@end
