//
//  JPMakeChatRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMakeChatRoomViewController.h"
#import "JPChatViewController.h"
#import "MapRecord.h"
#import "PinRecord.h"

@class CLLocation;

@interface JPMakeChatRoomViewController ()

@end

@implementation JPMakeChatRoomViewController

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
    self.title = @"Make Room";
    
    UIBarButtonItem *btnCreate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(createRoom:)];
    self.navigationItem.rightBarButtonItem = btnCreate;
    
//    textViewForRoomDesc.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.9f];
    textViewForRoomDesc.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];
//    textViewForRoomDesc.textColor = [UIColor whiteColor];
//    textFieldForRoomDesc.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:1.f];
    mapSelectionView.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:1.f];

    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = [appDelegate managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"m_MapTitle" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    mapListArray = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    UITapGestureRecognizer *grForResignKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:grForResignKeyboard];
    [grView addGestureRecognizer:grForResignKeyboard];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)hideKeyboard {
//    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [textFieldForRoomDesc resignFirstResponder];
    [textFieldForRoomMaxNum resignFirstResponder];
    [textFieldForRoomName resignFirstResponder];
    [textViewForRoomDesc resignFirstResponder];
    
}

- (IBAction)createRoom:(id)sender {
    NSString *isSectetRoom;
    if (switchForSecret.on) {
        isSectetRoom = @"true";
    }
    else {
        isSectetRoom = @"false";
    }
    
//    CLLocation *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentLocation"];
//    NSNumber *lat = [[NSUserDefaults standardUserDefaults] objectForKey:@"CL_lat"];
//    NSNumber *lng = [[NSUserDefaults standardUserDefaults] objectForKey:@"CL_lng"];
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lat"];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lng"];
    
    NSArray *keyArr = @[
                        @"chat_room_maker",
                        @"userName",
                        @"userPwd",
                        @"chat_room_name",
                        @"chat_room_description",
                        @"chat_room_lat",
                        @"chat_room_lng",
                        @"chat_room_is_close",
                        @"chat_room_no_of_people",
                        ];
    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         textFieldForRoomName.text,
                         textFieldForRoomDesc.text,
                         [NSNumber numberWithDouble:lat],
                         [NSNumber numberWithDouble:lng],
                         isSectetRoom,
                         textFieldForRoomMaxNum.text
                         ];
    //맵 데이터 전송하는게 빠짐 -> 내부 json 파싱할때 어레이랑 키로 추가해야할 듯.
//    NSJSONSerialization *jsonSerialization;
    
    
    
    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_CREATE_ROOM setDelegate:self];
    
    
    

}

- (IBAction)showMapSelectionView:(id)sender {
//    mapSelectionView.alpha = 1;
    mapSelectionView.hidden = NO;
    
}


- (IBAction)selectMap:(id)sender {
//    mapSelectionView.alpha = 0;

    mapSelectionView.hidden = YES;

    NSIndexPath *selectedIndexPath = [mapListTableView indexPathForSelectedRow];
    selectedMapRecord = [mapListArray objectAtIndex:selectedIndexPath.row];
//    NSLog(@"%li, %@", selectedIndexPath.row, selectedMapRecord.m_MapTitle);
    mapImageView.image = [UIImage imageWithData:selectedMapRecord.m_Image];

}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%li", indexPath.row);
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    }
    MapRecord *record = [mapListArray objectAtIndex:indexPath.row];
    cell.textLabel.text = record.m_MapTitle;
    

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mapListArray count];
}

#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"received");
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];

    if ([responseType isEqualToString:@"Create ChatRoom"] && [[dic objectForKey:@"message"] isEqualToString:@"success"]) {
        NSLog(@"채팅방 만들기 success");
        
//        [self.navigationController popViewControllerAnimated:YES];
        
        //Send map data
        NSArray *keyArr = @[
                   @"m_FinishDateStr",
//                   @"m_Image",
                   @"m_MapOwner",
                   @"m_MapTitle",
                   @"m_OwnRoom",
                   @"m_SavedLatitude",
                   @"m_SavedLatitudeDelta",
                   @"m_SavedLongitude",
                   @"m_SavedLongitudeDelta",
                   @"m_StartDateStr",
                   @"m_TotalBudget",
                   ];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-DD HH:mm:ss";
        
        NSArray *dataArr = @[
                    [dateFormatter stringFromDate:selectedMapRecord.m_FinishDate],
//                    nil,//image, temporary null
                    selectedMapRecord.m_Owner,
                    selectedMapRecord.m_MapTitle,
                    [dic objectForKey:@"cr_id"],
                    selectedMapRecord.m_SavedLatitude,
                    selectedMapRecord.m_SavedLatitudeDelta,
                    selectedMapRecord.m_SavedLongitude,
                    selectedMapRecord.m_SavedLongitudeDelta,
                    [dateFormatter stringFromDate:selectedMapRecord.m_StartDate],
                    selectedMapRecord.m_TotalBudget
                    ];

        JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_SEND_MAPDATA setDelegate:self];
    }

    else if([responseType isEqualToString:@"AddMap"]) {
        NSLog(@"Send Map Success");
        
        NSString *mapID = [[dic objectForKey:@"data"] objectForKey:@"m_MapId"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-DD HH:mm:ss";

        NSMutableArray *pinsMutableArray = [[NSMutableArray alloc] init];
        
        for (PinRecord *pin in selectedMapRecord.pins) {
            //add pins
            NSArray *keyArr = @[
                                @"p_Budget",
                                @"p_Description",
                                @"p_FinishDateStr",
                                @"p_Latitude",
                                @"p_Longitude",
                                @"p_MapId",
                                @"p_Order",
                                ];
            
            NSArray *dataArr = @[
                                 [pin.p_Budget stringValue],
                                 pin.p_Description,
                                 [dateFormatter stringFromDate:pin.p_FinishDate],
                                 [pin.p_Latitude stringValue],
                                 [pin.p_Longitude stringValue],
                                 mapID,
                                 [pin.p_Order stringValue],
                                 ];
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:dataArr forKeys:keyArr];
            [pinsMutableArray addObject:dic];
        }
        
        

        //얘네만 따로 그냥 하드코딩; 기존에 틀 벗어남

        NSURL *url = [NSURL URLWithString:URL_FOR_SEND_MULTIPLE_PINDATA];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSData *data = [NSJSONSerialization dataWithJSONObject:pinsMutableArray options:0 error:nil];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:data];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
        
//        JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_SEND_MULTIPLE_PINDATA setDelegate:self];
        
    }

    else if([responseType isEqualToString:@"AddPins"]) {
        NSLog(@"Send Pins Success");
        [self.navigationController popViewControllerAnimated:YES];
        
    }

    
    else if([responseType isEqualToString:@"fail"]) {
        NSLog(@"채팅방 만들기 fail");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Fail to create"
                              message:@"i said fail"
                              delegate:nil
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
