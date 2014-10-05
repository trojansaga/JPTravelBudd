//
//  JPJoinViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 9. 26..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPJoinViewController.h"

#import "JPChatViewController.h"
#import "PinRecord.h"
#import "JPChattingRoomMapViewController.h"
#import "JPMapAnnotation.h"
#import "JPPinInfoView.h"

@interface JPJoinViewController ()

@end

@implementation JPJoinViewController

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
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(join)];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(showInfoView)];
    
    self.navigationItem.rightBarButtonItems = @[infoButton,joinButton];
    
    
    
    
//    //mapview = loaded mapview
    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _mob = [appDelegate managedObjectContext];
    
    //map connection    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",URL_FOR_RETREIVE_MAPDATA_WITHOUT_ROOMID, _crID];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    //    [request setHTTPBody:data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    //mapview
    _chattingRoomViewController = [[JPChattingRoomMapViewController alloc] initWithNibName:@"JPChattingRoomMapViewController" bundle:nil];

    
    //

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)retrieveDataFromPrevious:(id)sender {
    JPChatViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];

}

- (void) showInfoView {
    if (infoView.hidden == YES) {
        infoView.hidden = NO;
    }
    else {
        infoView.hidden = YES;
    }
}



- (void) join {
    
    // 클릭시 조인되던 소스코드
//    NSString *crID = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
//    NSLog(@"crid = %@", crID);
    NSString *str = [NSString stringWithFormat:@"%@",_crID];
//    NSLog(@"class of crid = %@", [crID class]);
//    NSLog(@"class of str = %@", [str class]);
    
    
    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         _crID,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         ];
    NSArray *keyArr = @[
                        @"m_id",
                        @"cr_id",
                        @"userName",
                        @"userPwd",
                        ];
//    JPChatViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];

    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_ROOM_JOIN setDelegate:self];
    
//    chattingRoomViewController = [[JPChattingRoomViewController alloc] initWithNibName:@"JPChattingRoomViewController" bundle:nil];
//    chattingRoomViewController.m_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
//    chattingRoomViewController.cr_id_room = str;
//    chattingRoomViewController.chatRoomTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    //    [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"]; //this? or not?
    
//    NSLog(@"mid = %@, crid = %@", [chattingRoomViewController.m_id class], [chattingRoomViewController.cr_id_room class]);

    
    
//    [self.navigationController pushViewController:_chattingRoomViewController animated:YES];
}

#pragma mark - Connection delegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];
    
    
    if ([responseType isEqualToString:@"Joining ChatRoom"]) {
        NSLog(@"채팅방 조인하기 성공");
        
        //        NSString *crmID = [dic objectForKey:@"crm_id"];
        //
        //        chattingRoomViewController.crm_id = crmID;
        
        //        [self.navigationController pushViewController:chattingRoomViewController animated:YES];
        
        //        joinViewController = [[JPJoinViewController alloc] initWithNibName:@"JPJoinViewController" bundle:nil];
        //        joinViewController.chattingRoomViewController = chattingRoomViewController;
        //        [self.navigationController pushViewController:joinViewController animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //map data received
    else if ([responseType isEqualToString:@"GetMap"]) {
        NSLog(@"//Map data received//");
        
        NSDictionary *mapDataDic = [dic objectForKey:@"data"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        
        //info View
        labelForTitle.text = [mapDataDic objectForKey:@"m_MapTitle"];
        labelForBudget.text = [[mapDataDic objectForKey:@"m_TotalBudget"] stringValue];
        labelForStartDate.text = [mapDataDic objectForKey:@"m_StartDateStr"];
        labelForFinishDate.text = [mapDataDic objectForKey:@"m_FinishDateStr"];
        
        //map modulation
        double lat = [[mapDataDic objectForKey:@"m_SavedLatitude"] doubleValue];
        double lng = [[mapDataDic objectForKey:@"m_SavedLongitude"] doubleValue];
        double latDelta = [[mapDataDic objectForKey:@"m_SavedLatitudeDelta"] doubleValue];
        double lngDelta = [[mapDataDic objectForKey:@"m_SavedLongitudeDelta"] doubleValue];

//        //seoul temp value
//        double lat = 37.52828105087837;
//        double lng = 127.0977043415754;
//        double latDelta = 0.152065721159957;
//        double lngDelta = 0.1644502557309693;
        
        
//        NSLog(@"lat : %lf",lat);
//        NSLog(@"latD : %lf",latDelta);
//        NSLog(@"lng : %lf",lng);
//        NSLog(@"lngD : %lf",lngDelta);
        
        [mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), MKCoordinateSpanMake(latDelta, lngDelta))];
        
        //set pins
        NSArray *pinsArr = [mapDataDic objectForKey:@"pins"];
        for (NSDictionary *pin in pinsArr) {
            JPMapAnnotation *anno = [[JPMapAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake([[pin objectForKey:@"p_Latitude"] doubleValue], [[pin objectForKey:@"p_Longitude"] doubleValue]);
            anno.title = [pin objectForKey:@"p_Title"];
//            anno.title = @"temp title";
            anno.subtitle = [pin objectForKey:@"p_Description"];
            anno.order = [pin objectForKey:@"p_Order"];
            anno.budget = [pin objectForKey:@"p_Budget"];
//            anno.startDate = [dateFormatter dateFromString:[pin objectForKey:@"p_StartDateStr"]];
            anno.finishDate = [dateFormatter dateFromString:[pin objectForKey:@"p_FinishDateStr"]];
            
            [mapView addAnnotation:anno];
        }
        
        //draw lines
        pinsArr = [pinsArr sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSNumber *first = [a objectForKey:@"p_Order"];
            NSNumber *second = [b objectForKey:@"p_Order"];
            return [first compare:second];
        }];
        
        for (int i = 0; i < [pinsArr count]-1; i++) {
            MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
            
            double startLat = [[[pinsArr objectAtIndex:i] objectForKey:@"p_Latitude"] doubleValue];
            double startLng = [[[pinsArr objectAtIndex:i] objectForKey:@"p_Longitude"] doubleValue];
            double finLat = [[[pinsArr objectAtIndex:i+1] objectForKey:@"p_Latitude"] doubleValue];
            double finLng = [[[pinsArr objectAtIndex:i+1] objectForKey:@"p_Longitude"] doubleValue];
            
            
            MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(startLat, startLng) addressDictionary:nil];
            MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(finLat, finLng) addressDictionary:nil];

            [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:sourcePlacemark]];
            [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:destPlacemark]];
            
            directionsRequest.transportType = MKDirectionsTransportTypeWalking;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    routeData = [[response routes] lastObject];
                    [mapView addOverlay:routeData.polyline];
                    //                NSLog(@"one line is drawn.");
                }
            }];
        }
        

        
        
        
//        self.title = [mapDataDic objectForKey:@"m_MapTitle"];
        
//        labelForTitle.text = [mapDataDic objectForKey:@"m_MapTitle"];
//        labelForBudget.text = [mapDataDic objectForKey:@"m_TotalBudget"];
        
//        NSLog(@"%@", [mapDataDic objectForKey:@"m_MapTitle"]);
        
        
//        // 코어데이타로
//        //add map data
//        //////////
//        _mapData = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_mob];
//        _mapData.m_FinishDate = [dateFormatter dateFromString:[mapDataDic objectForKey:@"m_FinishDateStr"]];
//        _mapData.m_StartDate = [dateFormatter dateFromString:[mapDataDic objectForKey:@"m_StartDateStr"]];
//        _mapData.m_MapTitle = [mapDataDic objectForKey:@"m_MapTitle"];
//        _mapData.m_SavedLatitude = [mapDataDic objectForKey:@"m_SavedLatitude"];
//        _mapData.m_SavedLatitudeDelta = [mapDataDic objectForKey:@"SavedLatitudeDelta"];
//        _mapData.m_SavedLongitude = [mapDataDic objectForKey:@"m_SavedLongitude"];
//        _mapData.m_SavedLongitudeDelta = [mapDataDic objectForKey:@"SavedLongitudeDelta"];
//        _mapData.m_TotalBudget = [mapDataDic objectForKey:@"m_TotalBudget"];
//        
//        NSArray *pinsDataArr = [mapDataDic objectForKey:@"pins"];
//        for (NSDictionary *dic in pinsDataArr) {
//            //add pin annotation
//            /////////////////
//            //        _roomMapView addpin!!!!!
//            //        _roomMapView addAnnotation:
//            PinRecord *pin = [NSEntityDescription insertNewObjectForEntityForName:@"PinRecord" inManagedObjectContext:_mob];
//            pin.p_Budget = [dic objectForKey:@"p_Budget"];
//            pin.p_Description = [dic objectForKey:@"p_Description"];
//            pin.p_FinishDate = [dateFormatter dateFromString:[dic objectForKey:@"p_FinishDateStr"]];
//            //            pin.p_StartDate = [dateFormatter dateFromString:[dic objectForKey:@""]]//no start date
//            pin.p_Latitude = [dic objectForKey:@"p_Latitude"];
//            pin.p_Longitude =[dic objectForKey:@"p_Longitude"];
//            pin.p_Order = [dic objectForKey:@"p_Order"];
//            [_mapData addPinsObject:pin];
//        }
//        
//
//        _chattingRoomViewController.mapData = _mapData;
////        [_chattingRoomViewController refreshMap];
//        [_chattingRoomViewController refreshMap];
        


        

        
//        [_mob rollback];
    }
    
}


#pragma mark - mapview delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeData.polyline];
    routeLineRenderer.strokeColor = [UIColor brownColor];
    routeLineRenderer.lineWidth = 3;
    
    return routeLineRenderer;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass:[MKUserLocation class]]) {
        JPMapAnnotation *anno = (JPMapAnnotation *)[view annotation];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //    NSLog(@"click callout");
    JPMapAnnotation *annoData = view.annotation;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLog(@"%@", annoData.title);
    NSLog(@"%@", annoData.subtitle);
    NSLog(@"%@", [annoData.order stringValue]);
    NSLog(@"%@", [annoData.budget stringValue]);
//    NSLog(@"%@", [dateFormatter stringFromDate:annoData.startDate]);
    NSLog(@"%@", [dateFormatter stringFromDate:annoData.finishDate]);
    
    JPPinInfoView *pinInfoView = [[JPPinInfoView alloc] init];
    pinInfoView.textFieldForTitle.text = annoData.title;
    pinInfoView.textFieldForOrder.text = [annoData.order stringValue];
    
    [self.view addSubview:pinInfoView];
    [mapView addSubview:pinInfoView];
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
//        NSLog(@"here?1");
        if (!pinView)
        {
//            NSLog(@"here?2");
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            pinView.draggable = YES;
            
        } else {
//            NSLog(@"here?3");
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

@end
