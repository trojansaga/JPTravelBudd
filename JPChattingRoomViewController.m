//
//  JPChattingRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChattingRoomViewController.h"


#import "ChatRecord.h"
#import "JPChatContentCellTableViewCell.h"
#import "JPAppDelegate.h"
#import "JPMapAnnotation.h"
#import "JPMapViewController.h"
#import "PinRecord.h"


#define kChatContentsCellID     @"chatCellIdentifier"
#define kChatContentsCellIDMe   @"chatCellIdentifierForMe"


@interface JPChattingRoomViewController ()

@end

@implementation JPChattingRoomViewController

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
    
    nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"];
    appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    domain = @"@54.199.143.8";
    conferenceDomain = @"@conference.54.199.143.8/";
    conferenceDomain = [conferenceDomain stringByAppendingString:nickName];
    
    _mob = [appDelegate managedObjectContext];
    
    
    //chattingTableView UI
    chattingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    chattingTableView.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];

    //textfield
    
    [textFieldForMessage addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //navigationBar setting
    self.navigationItem.title = _chatRoomTitle;
    

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showMoreButtons)];
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showViewForMoreInfo)];

//    self.navigationItem.rightBarButtonItem = button;
    self.navigationItem.rightBarButtonItems = @[button,mapButton];
    
    [self.view addSubview:_viewForMoreButtons];
    _viewForMoreButtons.alpha = 0;



    
    //tap시 키보드 내리기
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:recognizer];

    

    //키보드 올림 노티 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReceived) name:@"newMsgArrival" object:nil];
    
   
    
    //map connection
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",URL_FOR_RETREIVE_MAPDATA_WITHOUT_ROOMID, _cr_id_room];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
//    [request setHTTPBody:data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
//    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate sendDataHttp:nil keyForDic:nil urlString:url setDelegate:self];
    
    //owner or member
    if (_isOwner == YES) {
        roomExitButton.titleLabel.text = @"Delete Room";
        //LongPress GestureRecognizer
        UILongPressGestureRecognizer *longPressGestureRecongnizer = [[UILongPressGestureRecognizer alloc]
                                                                     initWithTarget:self
                                                                     action:@selector(longPressed:)];
        [_roomMapView addGestureRecognizer:longPressGestureRecongnizer];

    }
    else {
        roomExitButton.titleLabel.text = @"Unjoin Room";
        buttonForPinEdit.hidden = YES;
        buttonForPinDelete.hidden = YES;
    }
    
//    [_viewForMoreButtons setFrame:CGRectMake(_viewForMoreButtons.frame.origin.x, _viewForMoreButtons.frame.origin.y, 320, self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height)];
//    _roomMapView.frame = CGRectMake(_roomMapView.frame.origin.x, _roomMapView.frame.origin.y, 320, _viewForMoreButtons.frame.size.height);

    
    
    //tabGR for date picker
    
    UITapGestureRecognizer *tapGRforStartDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerForStartDate)];
    UITapGestureRecognizer *tapGRforFinishDate = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerForFinishDate)];
    
    labelForPinStartDate.userInteractionEnabled = YES;
    labelForPinFinishDate.userInteractionEnabled = YES;
    [labelForPinStartDate addGestureRecognizer:tapGRforStartDate];
    [labelForPinFinishDate addGestureRecognizer:tapGRforFinishDate];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self enterRoom];
    [self refreshChattingContents];
    self.tabBarController.tabBar.hidden = YES;

    pinInfoView.hidden = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
//    [self refreshChattingContents];
    
    if ([chattingContents count] != 0) {
        // First figure out how many sections there are
        NSInteger lastSectionIndex = [chattingTableView numberOfSections] - 1;
        
        // Then grab the number of rows in the last section
        NSInteger lastRowIndex = [chattingTableView numberOfRowsInSection:lastSectionIndex] - 1;
        
        // Now just construct the index path
        NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
        
        [chattingTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    
//    chattingTableView.frame = CGRectMake(chattingTableView.frame.origin.x, chattingTableView.frame.origin.y, 320, 568 - 20 - 44);
//    chattingTableView.backgroundColor = [UIColor redColor];
    
//    NSLog(@"tabbar %f", self.tabBarController.tabBar.frame.size.height);
//    NSLog(@"navbar %f", self.navigationController.navigationBar.frame.size.height);
//    NSLog(@"self.view %f", self.view.frame.size.height);
//    NSLog(@"status view %f", [UIApplication sharedApplication].statusBarFrame.size.height);
//    NSLog(@"window view %f", [[UIScreen mainScreen] bounds].size.height);
//    NSLog(@"chatTableview %f", chattingTableView.frame.size.height);
//    NSLog(@"chatTableview(cont) %f", chattingTableView.contentSize.height);

    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [chattingTableView reloadData];
//        chattingTableView.contentOffset = CGPointMake(0, chattingTableView.contentSize.height);
//
//    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    [self exitRoom];//????????? 이거 왜한거임 도데체
    
    [self removeKeyboardNotification];

    [chattingContents removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMsgArrival" object:nil];

    
    self.tabBarController.tabBar.hidden = NO;
    
}


#pragma mark - Action

- (void)action {
    NSLog(@"af");
//    JPMapViewController *mapViewController = [[JPMapViewController alloc] initWithNibName:@"JPMapViewController" bundle:nil];
//    mapViewController.managedObjectContext = _mob;
//    mapViewController.mapRecord = _mapData;
//    
//    [self.navigationController pushViewController:mapViewController animated:YES];
    
}

- (IBAction)refreshPresence:(id)sender {
//    [self enterRoom];
    [self exitRoom];
    [self enterRoom];
}

- (IBAction)btnClick:(id)sender {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"count" object:@"stir"];
//    self.countOfChattingContents += 1;
    
//    NSLog(@"count : %i", _countOfChattingContents);
    
//    [self enterRoom];

    NSLog(@"contentOffset : (%f, %f)", chattingTableView.contentOffset.x, chattingTableView.contentOffset.y);
    NSLog(@"height %f, offset %f", chattingTableView.contentSize.height, chattingTableView.contentOffset.y        );
    
    
    // First figure out how many sections there are
    NSInteger lastSectionIndex = [chattingTableView numberOfSections] - 1;
    
    // Then grab the number of rows in the last section
    NSInteger lastRowIndex = [chattingTableView numberOfRowsInSection:lastSectionIndex] - 1;
    
    // Now just construct the index path
    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
    
    
    
    [chattingTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

-(void)refreshChattingContents {
    [chattingContents removeAllObjects];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatRecord" inManagedObjectContext:_mob];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
    
    [request setSortDescriptors:@[sort]];
    [request setEntity:entity];
    NSString *titleOfRoom = _cr_id_room;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromWhere == %@", titleOfRoom];
    
    [request setPredicate:predicate];
    chattingContents = [[_mob executeFetchRequest:request error:nil] mutableCopy];

//    NSLog(@"contentOffset : (%f, %f)", chattingTableView.contentOffset.x, chattingTableView.contentOffset.y);
//    NSLog(@"contentOffset : (%f, %f)", chattingTableView.contentOffset.x, chattingTableView.contentOffset.y);
//    NSLog(@"height %f, offset %f", chattingTableView.contentSize.height, chattingTableView.contentOffset.y        );
    
//    // First figure out how many sections there are
//    NSInteger lastSectionIndex = [chattingTableView numberOfSections] - 1;
//    
//    // Then grab the number of rows in the last section
//    NSInteger lastRowIndex = [chattingTableView numberOfRowsInSection:lastSectionIndex] - 1;
//    
//    // Now just construct the index path
//    NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];

//    [chattingTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    chattingTableView.contentOffset = CGPointMake(0, chattingTableView.contentSize.height);
    [chattingTableView reloadData];
}

-(void)msgReceived {

    ChatRecord *record = [chattingContents lastObject];
    if ([record.fromWhere isEqualToString:_cr_id_room]) {
        [self refreshChattingContents];
    }
}

#pragma mark - Map Data 

- (void) pinDataChangedSend {
    
}

- (void) pinAddSend {
    
}

- (IBAction)pinDelete:(id)sender {
    for (JPMapAnnotation *anno in [_roomMapView annotations]) {
        if ([anno.order isEqualToNumber:[NSNumber numberWithInt:[anno.order intValue]]]) {
            [_roomMapView removeAnnotation:anno];
            
            NSArray *data = @[
                              [NSNumber numberWithInt:[anno.pinId intValue]]
                              ];
            NSArray *key = @[
                             @"p_PinId"
                             ];
            
            [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_DELETE_PINDATA setDelegate:self];

        }
    }
    [self hidePinInfoView:nil];

    NSLog(@"deleted");

}

- (IBAction)refreshMap:(id)sender {
    //map connection
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",URL_FOR_RETREIVE_MAPDATA_WITHOUT_ROOMID, _cr_id_room];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    //    [request setHTTPBody:data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (IBAction)pinEdit:(id)sender{

    BOOL isFound = NO;
    //edit
    NSString *order = textFieldForPinOrder.text;
    for (JPMapAnnotation *anno in [_roomMapView annotations]) {
        if ([anno.order isEqualToNumber:[NSNumber numberWithInt:[order intValue]]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

            NSLog(@"edited");
            NSLog(@"%@,%@", anno.order, textFieldForPinOrder.text);
            anno.title = textFieldForPinTitle.text;
            anno.order = [NSNumber numberWithInt:[textFieldForPinOrder.text intValue]];
            anno.subtitle = textFieldForPinDesc.text;
            anno.budget = [NSNumber numberWithInt:[textFieldForPinBudget.text intValue]];
            anno.startDate = [dateFormatter dateFromString:labelForPinStartDate.text];
            anno.finishDate = [dateFormatter dateFromString:labelForPinFinishDate.text];
            
            isFound = YES;
            
            
            NSArray *data = @[
                              anno.title,
                              [anno.budget stringValue],
                              anno.subtitle,
                              [dateFormatter stringFromDate:anno.finishDate],
                              [dateFormatter stringFromDate:anno.startDate],
                              [NSNumber numberWithInt:p_MapId],
                              [anno.order stringValue],
                              anno.pinId
                              ];
            NSArray *key = @[
                             @"p_Title",
                             @"p_Budget",
                             @"p_Description",
                             @"p_FinishDateStr",
                             @"p_StartDateStr",
                             @"p_MapId",
                             @"p_Order",
                             @"p_PinId"
                             ];
            
            [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_UPDATE_PINDATA setDelegate:self];
            
            
        }
    }
    
    //add - not found from annotations
    if (isFound == NO) {
        NSLog(@"added");        
        JPMapAnnotation *anno = [[JPMapAnnotation alloc] init];
        anno.title = textFieldForPinTitle.text;
        anno.budget = [NSNumber numberWithInt:[textFieldForPinBudget.text intValue]];
        anno.subtitle = textFieldForPinDesc.text;
        anno.order = [NSNumber numberWithInt:[textFieldForPinOrder.text intValue]];
        anno.latitude = [NSNumber numberWithDouble:pinLatitude];
        anno.longitude = [NSNumber numberWithDouble:pinLongitude];
        
        [_roomMapView addAnnotation:anno];
        
        [self pinAddSend];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSArray *data = @[
                          anno.title,
                          [anno.budget stringValue],
                          anno.subtitle,
                          labelForPinFinishDate.text,
                          labelForPinStartDate.text,
                          anno.latitude,
                          anno.longitude,
                          [NSNumber numberWithInt:p_MapId],
                          [anno.order stringValue],
                          
                          ];
        NSArray *key = @[
                         @"p_Title",
                         @"p_Budget",
                         @"p_Description",
                         @"p_FinishDateStr",
                         @"p_StartDateStr",
                         @"p_Latitude",
                         @"p_Longitude",
                         @"p_MapId",
                         @"p_Order",

                         ];
        
        [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_SEND_PINDATA setDelegate:self];
    }
    
    
    [self hidePinInfoView:nil];
    
    
}


#pragma mark - Map UI

- (void)longPressed:(UILongPressGestureRecognizer *)gr {
    CGPoint touchPoint = [gr locationInView:_roomMapView];
    CLLocationCoordinate2D touchMapCoordinate = [_roomMapView convertPoint:touchPoint toCoordinateFromView:_roomMapView];
    
    pinLatitude = touchMapCoordinate.latitude;
    pinLongitude = touchMapCoordinate.longitude;
    
    
    [self showPinInfoView];
    
    buttonForPinDelete.hidden = YES;

}

- (IBAction)hidePinInfoView:(id)sender {
    pinInfoView.hidden = YES;
    textFieldForPinTitle.text = @"";
    textFieldForPinBudget.text = @"";
    textFieldForPinOrder.text = @"";
    textFieldForPinDesc.text = @"";

}

- (void)showPinInfoView {
    
    textFieldForPinOrder.text = [NSString stringWithFormat:@"%li", [_roomMapView.annotations count]];
    pinInfoView.hidden = NO;
}

- (void)drawLines {
    //draw lines
//    pinsArr = [_roomMapView annotations];
    NSArray *arr = [_roomMapView annotations];
    
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(JPMapAnnotation *)a order];
        NSNumber *second = [(JPMapAnnotation *)b order];
//        NSNumber *second = [b objectForKey:@"p_Order"];
        return [first compare:second];
    }];
    
    for (int i = 0; i < [arr count]-1; i++) {
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
        
        double startLat = [[[arr objectAtIndex:i] latitude] doubleValue];
        double startLng = [[[arr objectAtIndex:i] longitude] doubleValue];
        double finLat = [[[arr objectAtIndex:i+1] latitude] doubleValue];
        double finLng = [[[arr objectAtIndex:i+1] longitude] doubleValue];
        
        
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
                [_roomMapView addOverlay:routeData.polyline];
                //                NSLog(@"one line is drawn.");
            }
        }];
    }
}

- (void)showMoreButtons {
    if (_viewForMoreButtons.alpha == 1) {
        _viewForMoreButtons.alpha = 0;
        _viewForMoreInfo.hidden = YES;

        //restore
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
    else {
        [UIView animateWithDuration:0.1 animations:^{
            _viewForMoreButtons.alpha = 1;
        }];
        [self removeKeyboardNotification];
        

    }
    
//    if ([self.navigationItem.rightBarButtonItems count] == 1) {
//        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showMoreButtons)];
//        UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showViewForMoreInfo)];
//        self.navigationItem.rightBarButtonItems = @[button, mapButton];
//    }
//    else {
//        UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showViewForMoreInfo)];
//        self.navigationItem.rightBarButtonItems = @[mapButton];
//    }
}

- (void) showPickerForStartDate {
    //    NSLog(@"show picker");
//    [self hideKeyboard];
    
    labelForPinFinishDate.backgroundColor = [UIColor whiteColor];
    labelForPinStartDate.backgroundColor = [UIColor yellowColor];
//    pinFinishDateLabel.backgroundColor = [UIColor whiteColor];
//    pinStartDateLabel.backgroundColor = [UIColor yellowColor];
    
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
    
//    [self hideKeyboard];
    
    labelForPinFinishDate.backgroundColor = [UIColor yellowColor];
    labelForPinStartDate.backgroundColor = [UIColor whiteColor];
    
    [datePicker removeFromSuperview];
    
    if ([labelForPinStartDate.text isEqualToString:@"touch here"]) {
        [self showPickerForStartDate];
        return;
    }
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
    [datePicker addTarget:self action:@selector(changeFinishDate) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    
    NSDate *startDate = [formatter dateFromString:labelForPinStartDate.text];
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
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    labelForPinStartDate.text = [NSString stringWithFormat:@"%@",
                              [dateFormat stringFromDate:datePicker.date]];
}

- (void)changeFinishDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    labelForPinFinishDate.text = [NSString stringWithFormat:@"%@",
                               [dateFormat stringFromDate:datePicker.date]];
}

#pragma mark - UI

- (void) resignKeyboard {

    [textFieldForMessage resignFirstResponder];
    [textFieldForPinTitle resignFirstResponder];
    [textFieldForPinOrder resignFirstResponder];
    [textFieldForPinDesc resignFirstResponder];
    [textFieldForPinBudget resignFirstResponder];
    
    [datePicker removeFromSuperview];
    labelForPinFinishDate.backgroundColor = [UIColor whiteColor];
    labelForPinStartDate.backgroundColor = [UIColor whiteColor];
//    _viewForMoreButtons.alpha = 0;
}

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
    if([notification name] == UIKeyboardWillShowNotification)
    {
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - keyboardBounds.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    }
    else if([notification name] == UIKeyboardWillHideNotification)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardBounds.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    }
    [UIView commitAnimations];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) showViewForMoreInfo {

//    [self resignKeyboard];
//    NSNotification *noti = [[NSNotification alloc] initWithName:UIKeyboardDidHideNotification object:nil userInfo:nil];
//    [self keyboardWillAnimate:noti];
    if (_viewForMoreInfo.hidden == YES) {
        _viewForMoreInfo.hidden = NO;


    }
    else {
        _viewForMoreInfo.hidden = YES;
        
        
    }
}

#pragma mark - More Buttons

- (IBAction)selectMap:(id)sender {
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];

}

- (IBAction)exitRoom:(id)sender {
    if (_isOwner == YES) {
        [self deleteRoom:nil];
    }
    else {
        [self leaveRoom:nil];
    }
}

- (IBAction)showJoinedMember:(id)sender {
    NSLog(@"members =");
    NSDictionary *dic;
    for (dic in self.joinedMemberListArray) {
        NSLog(@"%@\n",[dic objectForKey:@"member_email"]);
    }
}

- (IBAction)deleteRoom:(id)sender {
    
    NSArray *data = @[
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                      _cr_id_room
                      ];
    NSArray *key = @[
                     @"userName",
                     @"userPwd",
                     @"cr_id"
                     ];

    [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_ROOM_DELETE setDelegate:self];
    
}

- (IBAction)leaveRoom:(id)sender {
    NSArray *data = @[
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                      _cr_id_room,
                      _crm_id,
                      ];

    NSArray *key = @[
                     @"userName",
                     @"userPwd",
                     @"cr_id",
                     @"crm_id"
                     ];
    [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_ROOM_EXIT setDelegate:self];
}

- (IBAction)showRoomInfo:(id)sender {
    NSString* url = [NSString stringWithFormat:@"%@%@",URL_FOR_ROOM_DESC_WITHOUT_CRID,_cr_id_room];
    [appDelegate sendDataHttp:nil keyForDic:nil urlString:url setDelegate:self];
}

- (IBAction)showMemberInfo:(id)sender {
    NSString* url = [NSString stringWithFormat:@"%@%@",URL_FOR_ROOM_JOINEDMEMBER_LIST_WITHOUT_CRID,_cr_id_room];
    [appDelegate sendDataHttp:nil keyForDic:nil urlString:url setDelegate:self];
}

#pragma mark - Send

- (void)sendMapData {
    
}

- (IBAction)sendMessage:(id)sender {
    NSString *str = [NSString stringWithString:textFieldForMessage.text];
    sendedString = str;

    if ([str isEqualToString:@""]) {
        return ;
    }
    
    NSArray *dataArr = @[
                         str,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         nickName,
                         _cr_id_room
                         
                         ];
    NSArray *keyArr = @[
                        @"message",
                        @"userPwd",
                        @"userName",
                        @"cr_id"
                        ];
    appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_GROUP_MESSAGE setDelegate:self];

    textFieldForMessage.text = @"";

}

- (void) sendGMxmpp {
   
//    // this procedure is for XMPP ONLY
//    
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:@"text"];
//    
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@54.199.143.8",self.friendNameLabel.text]];
//    [message addChild:body];
//    
//    
//    iPhoneXMPPAppDelegate *del = (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[del xmppStream] sendElement:message];
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:@"testios@54.199.143.8"];
//    [presence addAttributeWithName:@"id" stringValue:@"78"];
    [presence addAttributeWithName:@"to" stringValue:@"78@conference.54.199.143.8/nick"];
    JPAppDelegate *del = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[del xmppStream] sendElement:presence];
}


#pragma mark - Presence


- (void) enterRoom {
    //join the room with presence
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
//    NSLog(@"%@",_cr_id_room);
    
    NSString *from = [nickName stringByAppendingString:domain];
    NSString *to = [_cr_id_room stringByAppendingString:conferenceDomain];
    
    [presence addAttributeWithName:@"from" stringValue:from];
    [presence addAttributeWithName:@"to" stringValue:to];
    [[appDelegate xmppStream] sendElement:presence];
}

- (void) exitRoom {
    //presence.. unavailable -> not msg receivable
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
//    NSLog(@"%@",_cr_id_room);
    NSString *from = [nickName stringByAppendingString:domain];
    NSString *to = [_cr_id_room stringByAppendingString:conferenceDomain];
    
    [presence addAttributeWithName:@"from" stringValue:from];
    [presence addAttributeWithName:@"to" stringValue:to];
    [presence addAttributeWithName:@"type" stringValue:@"unavailable"];
//    [presence addAttributeWithName:@"type" stringValue:@"offline"];
    [[appDelegate xmppStream] sendElement:presence];
    
}

#pragma mark - TableView UI

- (void)configureCell:(JPChatContentCellTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JPChatContentCellTableViewCell class]])
    {
        ChatRecord *record = [chattingContents objectAtIndex:indexPath.row];
        cell.nameLabel.text = record.fromWho;
        cell.chatContents.text = record.body;
        
        NSString *time = [record.timeStamp substringFromIndex:14];
        cell.timeLabel.text = time;
        
        
        NSInteger heightOfCell = [record.body length] / 12;
        heightOfCell++;
        //    CGFloat heightOfRow = cell.frame.size.height*heightOfCell;
        //    [chattingTableView setRowHeight:heightOfRow];

        
        //왜 메인 큐에서 돌리면 될까......... 모리겓다........ 칠무해........
        //thread 상에서 ui가 메인큐라서 그른가??
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height*heightOfCell);
            [cell.chatContents setFrame:CGRectMake(cell.chatContents.frame.origin.x, cell.chatContents.frame.origin.y, cell.chatContents.frame.size.width, cell.chatContents.frame.size.height * heightOfCell)];

//            [cell.chatContents.layoutManager ensureLayoutForTextContainer:cell.chatContents.textContainer];
//            CGRect rect = [cell.chatContents.layoutManager usedRectForTextContainer:cell.chatContents.textContainer];
//            cell.chatContents.frame = CGRectMake(cell.chatContents.frame.origin.x, cell.chatContents.frame.origin.y, rect.size.width, rect.size.height);
            
//            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,cell.frame.size.width,  cell.chatContents.frame.size.height);
            
        });

//        [cell.chatContents setFrame:CGRectMake(cell.chatContents.frame.origin.x, cell.chatContents.frame.origin.y, cell.chatContents.frame.size.width, cell.chatContents.frame.size.height * heightOfCell)];
//        cell.chatContents.contentSize = CGSizeMake(cell.chatContents.contentSize.width, cell.chatContents.contentSize.height * heightOfCell);

        
//        NSLog(@"row: %ld, sieze %f, %f, %li", (long)indexPath.row, cell.frame.size.width, cell.frame.size.height, heightOfCell);
//        NSLog(@"cc/ %ld, size %f, %f", indexPath.row, cell.chatContents.frame.size.width, cell.chatContents.frame.size.height);
    
        
//        cell.backgroundColor = [UIColor colorWithRed:135 green:206 blue:235 alpha:0.8];
        cell.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:0.f];
    }
}


#pragma mark - TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([chattingContents count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        return cell;
    }
    
    ChatRecord* record = [chattingContents objectAtIndex:indexPath.row];
    JPChatContentCellTableViewCell *cell;
    
    //me
    if ([record.fromWho isEqualToString:nickName]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kChatContentsCellIDMe];
        if (cell == nil) {
            [chattingTableView registerNib:[UINib nibWithNibName:@"JPChatContentCellTableViewCellForMe" bundle:nil] forCellReuseIdentifier:kChatContentsCellIDMe];
            cell = [chattingTableView dequeueReusableCellWithIdentifier:kChatContentsCellIDMe];
        }
        
    }
    //others
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kChatContentsCellID];
        if (cell == nil) {
            [chattingTableView registerNib:[UINib nibWithNibName:@"JPChatContentCellTableViewCell" bundle:nil] forCellReuseIdentifier:kChatContentsCellID];
            cell = [chattingTableView dequeueReusableCellWithIdentifier:kChatContentsCellID];
        }
    }

    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([tableView isEqual:chattingTableView]) {
//        ChatRecord *record = [chattingContents objectAtIndex:indexPath.row];
//
//        NSInteger heightOfCell = [record.body length] / 12;
//        heightOfCell++;
//        //    CGFloat heightOfRow = cell.frame.size.height*heightOfCell;
//        //    [chattingTableView setRowHeight:heightOfRow];
//        return 44 * heightOfCell;
//    }
//    return 44;
//}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([tableView isEqual:chattingTableView]) {
//        JPChatContentCellTableViewCell *cell = (JPChatContentCellTableViewCell*)[chattingTableView cellForRowAtIndexPath:indexPath];
//        if (indexPath.row == 0) {
//            return 100;
//        }
//        if (cell.frame.size.height > 44) {
//            return 100;
//        }
//
//    }
//    return UITableViewAutomaticDimension;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chattingContents count];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}

#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];
    
    NSLog(@"response : %@", responseType);
    
    
    //채팅방 리스트
    if ([responseType isEqualToString:@"Delete ChatRoom"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([responseType isEqualToString:@"Deactivate ChatRoom Member"]) {
        NSLog(@"//채팅방 탈퇴하기//");
        NSLog(@"%@", [dic objectForKey:@"message"]);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([responseType isEqualToString:@"ChatRoom Info"]) {
        NSLog(@"//채팅방 정보//");
        NSLog(@"%@", [dic objectForKey:@"chat_room_name"]);
        
    }
    else if ([responseType isEqualToString:@"Member List"]) {
        NSLog(@"//채팅방 멤버 리스트//");
        NSArray *nameArr = [dic objectForKey:@"data"];
        for (NSDictionary* memberData in nameArr) {
            NSLog(@"%@", [memberData objectForKey:@"member_name"]);
        }

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
        
        //inner variable
        mapData = mapDataDic;
        
        
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
        
        
//        NSLog(@"lat : %.16lf",lat);
//        NSLog(@"latD : %.16lf",latDelta);
//        NSLog(@"lng : %.16lf",lng);
//        NSLog(@"lngD : %.16lf",lngDelta);
        
        [_roomMapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(lat, lng), MKCoordinateSpanMake(latDelta, lngDelta))];
        
        //set pins
        [_roomMapView removeAnnotations:[_roomMapView annotations]];
        
        pinsArr = [mapDataDic objectForKey:@"pins"];
        for (NSDictionary *pin in pinsArr) {
            JPMapAnnotation *anno = [[JPMapAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake([[pin objectForKey:@"p_Latitude"] doubleValue], [[pin objectForKey:@"p_Longitude"] doubleValue]);
            anno.title = [pin objectForKey:@"p_Title"];
            anno.subtitle = [pin objectForKey:@"p_Description"];
            anno.order = [pin objectForKey:@"p_Order"];
            anno.budget = [pin objectForKey:@"p_Budget"];
            anno.pinId = [pin objectForKey:@"p_PinId"];
            anno.startDate = [dateFormatter dateFromString:[pin objectForKey:@"p_StartDateStr"]];
            anno.finishDate = [dateFormatter dateFromString:[pin objectForKey:@"p_FinishDateStr"]];
            
            [_roomMapView addAnnotation:anno];
            NSNumber *num = [mapDataDic objectForKey:@"m_MapId"];
            p_MapId = [num intValue];
        }
        
        
        [self drawLines];

    }
    
    else if ([responseType isEqualToString:@"DelPin"]) {
        NSLog(@"//pin deleted//");
        
        //다끝내고 그림 그리기
        [_roomMapView removeOverlays:[_roomMapView overlays]];
        [self drawLines];

    }
    else if ([responseType isEqualToString:@"AddPin"]) {
        NSLog(@"//pin added//");
        
        //다끝내고 그림 그리기
        [_roomMapView removeOverlays:[_roomMapView overlays]];
        [self drawLines];

    }
    else if ([responseType isEqualToString:@"UpdatePin"]) {
        NSLog(@"//pin updated//");
        
        //다끝내고 그림 그리기
        [_roomMapView removeOverlays:[_roomMapView overlays]];
        [self drawLines];

//        NSLog(@"%@",[dic objectForKey:@"result"]);
    }

    
    else {

        //얘는 리턴이 그냥 스트링, about chatting messages
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        if ([str isEqualToString:@"Sending Success"]) {
            NSLog(@"send success");
            NSLog(@"------------------------------------------------------------------------------");
            
            NSString *body = sendedString;
            NSString *fromWho = nickName;
            NSString *fromWhere = _cr_id_room;
            
            ChatRecord *record = [NSEntityDescription insertNewObjectForEntityForName:@"ChatRecord" inManagedObjectContext:_mob];
            [record setBody:body];
            [record setFromWho:fromWho];
            [record setFromWhere:fromWhere];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy.MM.dd.HH.mm.ss";
            NSString *date = [formatter stringFromDate:[NSDate date]];
            
            [record setTimeStamp:date];
            
            
            NSLog(@"body = %@", body);
            NSLog(@"where = %@", fromWhere);
            NSLog(@"who = %@", fromWho);
            NSLog(@"date = %@", date);
            
            
            [_mob save:nil];
            
            
            
            [self refreshChattingContents];

            [self exitRoom];
            [self enterRoom];

            
            NSLog(@"------------------------------------------------------------------------------");
            
        }
        else {
            NSLog(@"send fail");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Fail to create"
                                  message:@"i said fail"
                                  delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil, nil];
            [alert show];
        }
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
    
//    NSLog(@"%@", annoData.title);
//    NSLog(@"%@", annoData.subtitle);
//    NSLog(@"%@", [annoData.order stringValue]);
//    NSLog(@"%@", [annoData.budget stringValue]);
//    NSLog(@"%@", [dateFormatter stringFromDate:annoData.startDate]);
//    NSLog(@"%@", [dateFormatter stringFromDate:annoData.finishDate]);
    
    textFieldForPinTitle.text = annoData.title;
    textFieldForPinOrder.text = [annoData.order stringValue];
    textFieldForPinBudget.text = [annoData.budget stringValue];
    textFieldForPinDesc.text = annoData.subtitle;
    labelForPinStartDate.text = [dateFormatter stringFromDate:annoData.startDate];
    labelForPinFinishDate.text = [dateFormatter stringFromDate:annoData.finishDate];
    
    pinInfoView.hidden = NO;
    if (_isOwner == YES) {
        buttonForPinDelete.hidden = NO;
    }
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
            if (_isOwner == YES) {
                pinView.draggable = YES;
            }

            
        } else {
            //            NSLog(@"here?3");
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (oldState == MKAnnotationViewDragStateEnding) {
        NSLog(@"drag ends");
        
        JPMapAnnotation *anno = view.annotation;
        
        NSArray *data = @[
                          anno.latitude,
                          anno.longitude,
                          [NSNumber numberWithInt:p_MapId],
                          anno.pinId
                          ];
        NSArray *key = @[
                         @"p_Latitude",
                         @"p_Longitude",
                         @"p_MapId",
                         @"p_PinId"
                         ];
        
        [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_UPDATE_PINDATA setDelegate:self];
    }
}

@end

