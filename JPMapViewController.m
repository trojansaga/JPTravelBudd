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

@synthesize totalBudget = totalBudget;

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
    titleLabel = [[UILabel alloc] init];
    titleBudgetLabel = [[UILabel alloc] init];
    titleRangeLabel = [[UILabel alloc] init];

//    //원래는 이설정
//    [titleLabel setFrame:CGRectMake(0, 0, (self.view.bounds.size.width - self.navigationItem.leftBarButtonItem.width - self.navigationItem.rightBarButtonItem.width), self.navigationController.navigationBar.bounds.size.height)];
//    titleLabel.backgroundColor = [UIColor brownColor];
//    self.navigationItem.titleView = titleLabel;

    
    double widthForTitleView = (200);
    double heightForTitleView = self.navigationController.navigationBar.bounds.size.height/2;
//    NSLog(@"width : %f, height : %f", widthForTitleView, heightForTitleView);
//    //이거 안해서 자꾸 제스쳐레코그나이저 안됫엇음 짜증남. 이게 기본 세팅이 노우로 되어있어요.
//    [titleLabel setUserInteractionEnabled:YES];
//    
    //TapGestureRecongnizer
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(changeTitle)];
    tg.numberOfTapsRequired = 1;
    tg.numberOfTouchesRequired = 1;
//    [titleLabel addGestureRecognizer:tg];
    
//    self.navigationItem.titleView = titleLabel;

    //이부분부터 임시설정
    
    UIView *customTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (self.view.bounds.size.width - self.navigationItem.leftBarButtonItem.width - self.navigationItem.rightBarButtonItem.width), self.navigationController.navigationBar.bounds.size.height)];
    [customTitleView setUserInteractionEnabled:YES];
    [customTitleView addGestureRecognizer:tg];
    [titleLabel setFrame:CGRectMake(0, 22, widthForTitleView, heightForTitleView)];
    [titleBudgetLabel setFrame:CGRectMake(widthForTitleView/2, 0, widthForTitleView/2-10, heightForTitleView)];
    [titleRangeLabel setFrame:CGRectMake(0, 0, widthForTitleView/2 - 2, heightForTitleView)];

//    titleBudgetLabel.backgroundColor = [UIColor brownColor];
//    titleRangeLabel.backgroundColor = [UIColor greenColor];
    
    [customTitleView addSubview:titleLabel];
    [customTitleView addSubview:titleBudgetLabel];
    [customTitleView addSubview:titleRangeLabel];
    
    [titleRangeLabel setTextAlignment:NSTextAlignmentLeft];
    [titleBudgetLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    
    self.navigationItem.titleView = customTitleView;


    
    
    
    //LongPress GestureRecognizer
    UILongPressGestureRecognizer *longPressGestureRecongnizer = [[UILongPressGestureRecognizer alloc]
                                                                 initWithTarget:self
                                                                 action:@selector(longPressOnMapView:)];
    [_mapView addGestureRecognizer:longPressGestureRecongnizer];
    
    
    [pinSaveView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    [self.view addSubview:pinSaveView];
    [pinSaveView setAlpha:0];

    _pins = [[NSMutableArray alloc] init];

    //tabGestureRecognizer for resign keyboard
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardAndPickerView)];
    [_mapView addGestureRecognizer:tapGestureRecognizer1];

    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardAndPickerView)];
    [pinSaveView addGestureRecognizer:tapGestureRecognizer2];
    
    
    //tabGR for date picker

    UITapGestureRecognizer *tapGRforStartDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerForStartDate)];
    UITapGestureRecognizer *tapGRforFinishDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerForFinishDate)];

    pinStartDateLabel.userInteractionEnabled = YES;
    pinFinishDateLabel.userInteractionEnabled = YES;
    [pinStartDateLabel addGestureRecognizer:tapGRforStartDate];
    [pinFinishDateLabel addGestureRecognizer:tapGRforFinishDate];
    
    
    
    //키보드 상단 확인/취소 버튼
//    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
//    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
//    numberToolbar.items = [NSArray arrayWithObjects:
//                           [[UIBarButtonItem alloc]initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:self action:@selector()],
//                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                           [[UIBarButtonItem alloc]initWithTitle:@"확인" style:UIBarButtonItemStyleDone target:self action:@selector()],
//                           nil];
//    [numberToolbar sizeToFit];
//    pinTextFieldForBudget.inputAccessoryView = numberToolbar;

    
    

    [self addObserver:self forKeyPath:@"totalBudget" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

    
    
    
    
    //키보드 올림 노티 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self removeObserver:self forKeyPath:@"totalBudget"];
    [_pins enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"budget"];
        [obj removeObserver:self forKeyPath:@"startDate"];
        [obj removeObserver:self forKeyPath:@"finishDate"];
    }];
    
    [self removeKeyboardNotification];
    
    [_managedObjectContext rollback];
    // 세이브 안하고 뒤로 가기를 눌렀을 때만, 롤백을 하게 할라고 함.

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = @"noname";


    NSDate *startDate;
    NSDate *finishDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd - HH/mm"];

    totalBudget = 0;
    
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
       
        
        startDate = [NSDate dateWithTimeIntervalSinceNow:0];
        finishDate = [NSDate dateWithTimeIntervalSinceNow:0];
        pinStartDateLabel.text = [dateFormatter stringFromDate:startDate];
        pinFinishDateLabel.text = [dateFormatter stringFromDate:finishDate];
    }
    

    
    // 존재하는 시키
    else {
        titleLabel.text = [_mapRecord m_MapTitle];
        
        numberOfPins = [_mapRecord.pins count];
        
        totalBudget = [_mapRecord.m_TotalBudget intValue];

        titleBudgetLabel.text = [NSString stringWithFormat:@"cost:%@$", [_mapRecord.m_TotalBudget stringValue]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd"];
        NSString *strForTitleRange = [NSString stringWithFormat:@"%@~%@", [dateFormatter stringFromDate:_mapRecord.m_StartDate], [dateFormatter stringFromDate:_mapRecord.m_FinishDate]];
        titleRangeLabel.text = strForTitleRange;

        
        double savedLatitude = [_mapRecord.m_SavedLatitude doubleValue];
        double savedLongitude = [_mapRecord.m_SavedLongitude doubleValue];
        double savedLatitudeDelta = [_mapRecord.m_SavedLatitudeDelta doubleValue];
        double savedLongitudeDelta = [_mapRecord.m_SavedLongitudeDelta doubleValue];

        [_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(savedLatitude, savedLongitude), MKCoordinateSpanMake(savedLatitudeDelta, savedLongitudeDelta))];
        
        
        
        for (PinRecord *pin in _mapRecord.pins) {
            
            double longitude = [pin.p_Longitude doubleValue];
            double latitude = [pin.p_Latitude doubleValue];
            
            JPMapAnnotation *pinMark = [[JPMapAnnotation alloc] init];
            [pinMark setTitle:pin.p_Title];
            [pinMark setSubtitle:pin.p_Description];
            [pinMark setStartDate:pin.p_StartDate];
            [pinMark setFinishDate:pin.p_FinishDate];
            pinStartDateLabel.text = [dateFormatter stringFromDate:pinMark.startDate];
            pinFinishDateLabel.text = [dateFormatter stringFromDate:pinMark.finishDate];
            
            [pinMark setCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            [pinMark setBudget:pin.p_Budget];

            [pinMark setOrder:pin.p_Order];

            [_mapView addAnnotation:pinMark];
            [_pins addObject:pinMark];
            [pinMark addObserver:self forKeyPath:@"budget" options:NSKeyValueObservingOptionNew context:nil];
            [pinMark addObserver:self forKeyPath:@"startDate" options:0 context:nil];
            [pinMark addObserver:self forKeyPath:@"finishDate" options:0 context:nil];

        }
        
        
        //다끝내고 그림 그리기
        [_mapView removeOverlays:[_mapView overlays]];
        [self drawLines];
        
        [self calculateRangeOfTravel];
//        [self calculateBudget];// no need?!?

    }

}



#pragma mark - PickerView Action

- (void) showPickerForStartDate {
//    NSLog(@"show picker");
    [self hideKeyboard];

    pinFinishDateLabel.backgroundColor = [UIColor whiteColor];
    pinStartDateLabel.backgroundColor = [UIColor yellowColor];
    
    [datePicker removeFromSuperview];
    
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [datePicker addTarget:self action:@selector(changeStartDate) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:datePicker];
    datePicker.frame = CGRectMake(0, self.view.frame.size.height - datePicker.frame.size.height, self.view.frame.size.width, datePicker.frame.size.height);
    datePicker.backgroundColor = [UIColor whiteColor];
    
    self.tabBarController.tabBar.hidden = YES;
    
    //    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    //    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    //    numberToolbar.items = [NSArray arrayWithObjects:
    //                           [[UIBarButtonItem alloc] initWithTitle:@"title" style:UIBarButtonSystemItemDone target:self action:@selector(removePicker)],
    //                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil],
    //                         nil];
    //    [numberToolbar sizeToFit];
    //
    //    [datePicker addSubview:numberToolbar];
    //    [numberToolbar setFrame:CGRectMake(0, datePicker.frame.size.height-numberToolbar.frame.size.height, numberToolbar.frame.size.width, numberToolbar.frame.size.height)];
    
    
    
    
    //    //action sheet
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc]
    //                             initWithTitle:nil
    //                             delegate:self
    //                             cancelButtonTitle:nil
    //                             destructiveButtonTitle:nil
    //                             otherButtonTitles:nil, nil];
    //    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    //    UIToolbar *datePickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //    datePickerToolBar.barStyle = UIBarStyleDefault;
    //    [datePickerToolBar sizeToFit];
    //    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    //    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(removePicker)];
    //    [barItems addObject:btnDone];
    //
    //    [actionSheet addSubview:datePickerToolBar];
    //    [actionSheet addSubview:datePicker];
    //
    //    [actionSheet showInView:self.view];
    //    [actionSheet setBounds:CGRectMake(0, 0, 320, 500)];
    
    
    
}

- (void) showPickerForFinishDate {

    [self hideKeyboard];
    
    pinStartDateLabel.backgroundColor = [UIColor whiteColor];
    pinFinishDateLabel.backgroundColor = [UIColor yellowColor];
    
    [datePicker removeFromSuperview];
    
    if ([pinStartDateLabel.text isEqualToString:@"touch here"]) {
        [self showPickerForStartDate];
        return;
    }
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [datePicker addTarget:self action:@selector(changeFinishDate) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd-HH:mm";
    
    
    NSDate *startDate = [formatter dateFromString:pinStartDateLabel.text];
    datePicker.date = startDate;
    datePicker.minimumDate = startDate;
    datePicker.maximumDate = [NSDate dateWithTimeInterval:60*60*24*7 sinceDate:startDate];
    
//    NSLog(@"min: %@, max: %@", [formatter stringFromDate:startDate], [formatter stringFromDate:datePicker.maximumDate]);
    datePicker.minuteInterval = 5;
    
    [self.view addSubview:datePicker];
    datePicker.frame = CGRectMake(0, self.view.frame.size.height - datePicker.frame.size.height, self.view.frame.size.width, datePicker.frame.size.height);
    datePicker.backgroundColor = [UIColor whiteColor];
    
    self.tabBarController.tabBar.hidden = YES;
    
}

- (void)changeStartDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd-HH:mm"];
    pinStartDateLabel.text = [NSString stringWithFormat:@"%@",
                              [dateFormat stringFromDate:datePicker.date]];
}

- (void)changeFinishDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd-HH:mm"];
    pinFinishDateLabel.text = [NSString stringWithFormat:@"%@",
                               [dateFormat stringFromDate:datePicker.date]];
}


#pragma mark - Action

- (void)calculateBudget {
    totalBudget = 0;
    for (JPMapAnnotation* pin in _pins) {
        
        totalBudget += [pin.budget intValue];
        self.totalBudget = totalBudget;
//        NSLog(@"totalBudget = %i", totalBudget);
    }
    
}

- (void) calculateRangeOfTravel {
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*365*10];
    NSDate *finishDate = [NSDate dateWithTimeIntervalSince1970:0];

    for (JPMapAnnotation* pin in _pins) {
        if ([pin.startDate compare:startDate] == NSOrderedAscending) {
            startDate = pin.startDate;
        }
        if ([pin.finishDate compare:finishDate] == NSOrderedDescending) {
            finishDate = pin.finishDate;
        }
    }

    self.totalStartDate = startDate;
    self.totalFinishDate = finishDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy, MM/dd-HH:mm"];
    [dateFormatter setDateFormat:@"MM/dd"];
//    NSLog(@"st: %@, fn: %@", [dateFormatter stringFromDate:self.totalStartDate], [dateFormatter stringFromDate:self.totalFinishDate]);
    
    NSString *strForTitleRange = [NSString stringWithFormat:@"%@~%@", [dateFormatter stringFromDate:self.totalStartDate], [dateFormatter stringFromDate:self.totalFinishDate]];
    titleRangeLabel.text = strForTitleRange;

}

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
//    [_mapView removeOverlays:[_mapView overlays]];
//    [self drawLines];
//    NSLog(@"pins in core data : %i\n pins in mapview : %i", [_mapRecord.pins count], [_pins count]);
//    [self.view addSubview:testPicker];
    
    
    static int num = 1;
    [self setCenterCoordinate:curPos zoomLevel:num animated:YES];

//    NSLog(@"zoom : %i", num++);
    
}

- (void) saveCurrentMap {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Saved"
                              message:@"success"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"ok", nil];
    [alertView show];

    //set title
    [_mapRecord setM_MapTitle:titleLabel.text];

    //save region
    [_mapRecord setM_SavedLatitude:[NSNumber numberWithDouble:_mapView.centerCoordinate.latitude]];
    [_mapRecord setM_SavedLongitude:[NSNumber numberWithDouble:_mapView.centerCoordinate.longitude]];
    [_mapRecord setM_SavedLatitudeDelta:[NSNumber numberWithDouble:_mapView.region.span.latitudeDelta]];
    [_mapRecord setM_SavedLongitudeDelta:[NSNumber numberWithDouble:_mapView.region.span.longitudeDelta]];
    
    //save range(date)
    [_mapRecord setM_StartDate:self.totalStartDate];
    [_mapRecord setM_FinishDate:self.totalFinishDate];
    
    //remove all pins
    [_mapRecord removePins:_mapRecord.pins];
    
    // image capture
    UIImage *image;
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, 411));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //transform into nsdata (for core data)
    NSData *imageData = UIImagePNGRepresentation(image);
    self.mapRecord.m_Image = imageData;

    int sumOfBudget = 0;
    
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
        sumOfBudget += [anno.budget intValue];

    }
    _mapRecord.m_TotalBudget = [NSNumber numberWithInt:sumOfBudget];
    [_managedObjectContext save:nil];
    

}

- (void) clickPinEditButton {
    
    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
}

- (void) longPressOnMapView: (UIGestureRecognizer *)gestureRecognizer {
    
    JPMapAnnotation *anno;
    int numberOfOrder = numberOfPins;
    BOOL isFoundOrder = YES;

    for (int i = 0; i < numberOfPins ; i++) {
        isFoundOrder = YES;
        
        for (int j = 0; j < _pins.count; j++) {
            anno = [_pins objectAtIndex:j];
            if (i == [anno.order intValue]) {
                isFoundOrder = NO;
                break;
            }
        }
        if (isFoundOrder == YES) {
            numberOfOrder = i;
            break;
        }
    }

    pinTextFieldForOrder.text = [NSString stringWithFormat:@"%i", numberOfOrder];
    pinTextFieldForTitle.text = @"title";
    pinTextFieldForDescription.text = @"";
    pinTextFieldForBudget.text = @"0";
    
    pinStartDateLabel.text = @"touch here";
    pinFinishDateLabel.text = @"touch here";
    
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
//                NSLog(@"wow");
            }
        }];
    
}


#pragma mark - Keyboard & Pickerview Action

- (void)keyboardWillAnimate:(NSNotification *)notification
{
    
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if ([pinTextFieldForDescription isFirstResponder]) {
        if([notification name] == UIKeyboardWillShowNotification)
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, + 100 + self.view.frame.origin.y - keyboardBounds.size.height + self.tabBarController.tabBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        }
        
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, - 100 + self.view.frame.origin.y + keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        }
    }
    else {
        NSLog(@"?");
        [self.view setFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height)];
    }
    
    
    [UIView commitAnimations];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)hideKeyboard {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void) hideKeyboardAndPickerView {
//    [self.view endEditing:YES];
    
    
//    [pinTextFieldForTitle resignFirstResponder];
//    [pinTextFieldForOrder resignFirstResponder];
//    [pinTextFieldForBudget resignFirstResponder];
//    [pinTextFieldForDescription resignFirstResponder];
    
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//    [[UIApplication sharedApplication] resignFirstResponder];

    //temp
    [datePicker removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
    
    pinStartDateLabel.backgroundColor = [UIColor whiteColor];
    pinFinishDateLabel.backgroundColor = [UIColor whiteColor];
    
//    NSLog(@"hide keyboard & pickerview");
    
    
//    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [obj resignFirstResponder];
//    }];
    
}



#pragma mark - MapView Control

- (void) drawLines {
    
    // 임의적으로 기냥 새 인스턴스를 만들어서 그림만 그린다.. 문제가 있음
//    NSLog(@"pins count : %d", [_pins count]);
    int count = _pins.count;
//    NSLog(@"count : %i", count);
    
    // temp sortedArray for drawing only
    NSArray *sortedArray;
    if (count == 0) {
        return;
    }
    
    sortedArray = [_pins sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(JPMapAnnotation *)a order];
        NSNumber *second = [(JPMapAnnotation *)b order];
        return [first compare:second];

    }];
    
    for (int i = 0; i < [sortedArray count]-1; i++) {
        //        JPMapAnnotation *pinMark = [_pins objectAtIndex:i];
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        //        [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:i]]];
        //        [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:[_pins objectAtIndex:(i+1)]]];
        
        // 요 부분이, mkplacemark를 새로 만들어서 그림을 그려줌. 이거 나중에 문제될듯.
        // 아마 나중에 삭제하는 부분에서 문제가 발생할 것으로 예상됩니다 허허
        
//        CLLocationCoordinate2D *sourceCoord;
//        CLLocationCoordinate2D *destCoord;
//        
//        [_pins enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            JPMapAnnotation *pin = obj;
//            if (pin.order == i) {
//                CLLocationCoordinate2D *sourceCord = CLLocationCoordinate2DMake(pin.coordinate.latitude, pin.coordinate.longitude);
//            }
//        }];
        
        switch (i/3) {
            case 0:
//                routeLineRenderer.strokeColor = [UIColor blueColor];
                [routeLineRenderer setFillColor:[UIColor blueColor]];
                break;
            case 1:
//                routeLineRenderer.strokeColor = [UIColor redColor];
                break;
            case 2:
//                routeLineRenderer.    MKPolylineRenderer  * routeLineRenderer;strokeColor = [UIColor greenColor];
                break;
            default:
                break;
        }
        
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[[sortedArray objectAtIndex:i] coordinate] addressDictionary:nil];
        MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:[[sortedArray objectAtIndex:i+1] coordinate] addressDictionary:nil];
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
//                NSLog(@"one line is drawn.");
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



#pragma mark - Annotation Action

- (IBAction)cancelLongPress:(id)sender {
    [pinSaveView setAlpha:0];
}

- (IBAction)deletePin:(id)sender {
//    UIButton *button = sender;
    NSLog(@"delete pin, %@", [[(UIButton *)sender titleLabel] text]);
    [_mapView removeAnnotation:pinAnnotation];
    [_pins removeObject:pinAnnotation];

    [pinSaveView setAlpha:0];
    
    //다끝내고 그림 그리기
    [_mapView removeOverlays:[_mapView overlays]];
    [self drawLines];
    
    //budget
//    self.totalBudget -= [pinAnnotation.budget intValue];

    [self calculateBudget];
    [self calculateRangeOfTravel];
    //remove observer
    [pinAnnotation removeObserver:self forKeyPath:@"budget"];
    [pinAnnotation removeObserver:self forKeyPath:@"startDate"];
    [pinAnnotation removeObserver:self forKeyPath:@"finishDate"];
    
    
}

- (IBAction)clickPinSaveButton:(id)sender {
    
    if ([pinTextFieldForBudget.text isEqualToString:@""]
        //        || [pinTextFieldForDescription.text isEqualToString:@""]
        || [pinTextFieldForOrder.text isEqualToString:@""]
//        || [pinStartDateLabel.text isEqualToString:@"touch here"]
//        || [pinFinishDateLabel.text isEqualToString:@"touch here"]
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
    
    
    //temp
//    NSString *str = [NSString stringWithFormat:@"%@%@",pinTextFieldForDescription.text, pinTextFieldForOrder.text];
//    pinTextFieldForDescription.text = str;
    
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
            
          

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd-HH:mm"];
            
            [pinMark setStartDate:[dateFormatter dateFromString:pinStartDateLabel.text]];
            [pinMark setFinishDate:[dateFormatter dateFromString:pinFinishDateLabel.text]];
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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd-HH:mm"];
        
        [pinMark setStartDate:[dateFormatter dateFromString:pinStartDateLabel.text]];
        [pinMark setFinishDate:[dateFormatter dateFromString:pinFinishDateLabel.text]];
        
        [pinMark addObserver:self forKeyPath:@"budget" options:NSKeyValueObservingOptionNew context:nil];
        [pinMark addObserver:self forKeyPath:@"startDate" options:0 context:nil];
        [pinMark addObserver:self forKeyPath:@"finishDate" options:0 context:nil];
        
        [_mapView addAnnotation:pinMark];
        [_pins addObject:pinMark];
        numberOfPins++; // increase pin number by 1.
    }
    
    //다끝내고 그림 그리기
    [_mapView removeOverlays:[_mapView overlays]];
    [self drawLines];
    
    //budget
    [self calculateBudget];
    [self calculateRangeOfTravel];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"ok");
//    NSLog(@"keypath : %@", keyPath);
//    NSLog(@"change : %@", change);
//    NSLog(@"context : %@", context);
//    NSLog(@"object : %@", object);
    
    if ([keyPath isEqual:@"budget"]) {
        //calculate budget
        [self calculateBudget];
    }
    if ([keyPath isEqual:@"totalBudget"]) {
//        NSLog(@"totalbudget");
        titleBudgetLabel.text = [NSString stringWithFormat:@"cost:%i$", self.totalBudget];
    }
    if ([keyPath isEqual:@"finishDate"] || [keyPath isEqual:@"startDate"]) {
        NSLog(@"calculateRangeOfTravel");
        [self calculateRangeOfTravel];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    [textField resignFirstResponder];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *cordd = locations.lastObject;
    curPos = [cordd coordinate];
//    NSLog(@"%lf,%f", curPos.latitude, curPos.longitude);
//    [mapView setCenterCoordinate:curPos];
//    [manager stopUpdatingLocation];

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
            
//            NSString *title = [NSString stringWithFormat:@"%@/%@", textFieldForTitle.text, [_mapRecord.m_TotalBudget stringValue]];
//            titleLabel.text = title;
            
            titleLabel.text = textFieldForTitle.text;

        }
    }

}




#pragma mark - MapView Delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeData.polyline];
    routeLineRenderer.strokeColor = [UIColor brownColor];
    routeLineRenderer.lineWidth = 3;
    
    return routeLineRenderer;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (![view.annotation isKindOfClass:[MKUserLocation class]]) {
        JPMapAnnotation *anno = (JPMapAnnotation *)[view annotation];
//        NSLog(@"click anno, %@", [anno order]);
//        NSLog(@"coordinate : (%f, %f)",anno.coordinate.latitude,anno.coordinate.longitude);
        pinAnnotation = anno;
        deleteButton.hidden = NO;
    }
    
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    NSLog(@"click callout");
    JPMapAnnotation *annoData = view.annotation;
    pinTextFieldForTitle.text = annoData.title;
    pinTextFieldForDescription.text = annoData.subtitle;
    pinTextFieldForOrder.text = [NSString stringWithFormat:@"%i",[annoData.order intValue]];
    pinTextFieldForBudget.text = [NSString stringWithFormat:@"%i", [annoData.budget intValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd-HH:mm"];
    
    pinStartDateLabel.text = [dateFormatter stringFromDate:annoData.startDate];
    pinFinishDateLabel.text = [dateFormatter stringFromDate:annoData.finishDate];
    
    [UIView animateWithDuration:0.3 animations:^{
        [pinSaveView setAlpha:1];
    }];
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    //다끝내고 그림 그리기
    [_mapView removeOverlays:[_mapView overlays]];
    [self drawLines];

    
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
