//
//  JPChatViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChatViewController.h"
#import "JPMakeChatRoomViewController.h"
#import "JPChattingRoomViewController.h"
#import "JPJoinViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface JPChatViewController ()

@end

@implementation JPChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //total list
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"XMPPJID"];
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lat"];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lng"];
    NSArray *objects = @[
                         [NSNumber numberWithDouble:lat],
                         [NSNumber numberWithDouble:lng],
                         str
                         ];
    NSArray *keys = @[
                      @"chat_room_lat",
                      @"chat_room_lng",
                      @"userEmail"
                      ];
    
    [appDelegate sendDataHttp:objects keyForDic:keys urlString:URL_FOR_ROOM_LIST setDelegate:self];
    
    
    /////////////////////////////조인드 리스트는 응답없고, 위에 토탈 리스트는 조인안된애들은 안불러와야하는게 맞당
    
    //joined list
    
    objects = @[
                         str
                         ];
    keys = @[
                      @"member_email"
                      
                      ];
    
    
    [appDelegate sendDataHttp:objects keyForDic:keys urlString:URL_FOR_ROOM_MYLIST setDelegate:self];
    
    //로딩 바 돌아감
//    UIView *loadingBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    loadingBGView.backgroundColor = [UIColor blackColor];
//    loadingBGView.alpha = 0.2;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [indicator setColor:[UIColor blackColor]];
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self showNearMembers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationItem.title = @"Chatting";

    //translucent로 해야 사이즈가 맞어....왠지 몰라 썅
    self.navigationController.navigationBar.translucent = NO;
//    chatRoomListTableView.backgroundColor = [UIColor purpleColor];
    
    UIBarButtonItem *makeRoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(makeRoom:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTableView:)];

    self.navigationItem.leftBarButtonItem = refreshButton;
    self.navigationItem.rightBarButtonItem = makeRoomButton;

    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.2f];
    
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];
//    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];
//    self.navigationController.navigationBar.backgroundColor = [UIColor purpleColor];
//    self.navigationItem.titleView.backgroundColor = [UIColor purpleColor];
//    self.navigationController.navigationItem.titleView.backgroundColor = [UIColor purpleColor];
//
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor purpleColor]];
//    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
//    self.navigationController.navigationBar.tintColor = [UIColor brownColor];

    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.2f];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    

    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    

//    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];

    
    chatRoomListArray = [[NSMutableArray alloc] init];
    nearMembersArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Func

- (void) showNearMembers {
    NSArray *data = @[
                      [NSNumber numberWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lat"]],
                      [NSNumber numberWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lng"]],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                      ];
    NSArray *key = @[
                     @"ml_latitude",
                     @"ml_longitude",
                     @"ml_m_id"
                     ];
    
    
    [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_RETREIVE_USERS_IN_10KM setDelegate:self];
}

- (IBAction)reloadTableView:(id)sender {
    //total list
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"XMPPJID"];
    double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lat"];
    double lng = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CL_lng"];
    NSArray *objects = @[
                         [NSNumber numberWithDouble:lat],
                         [NSNumber numberWithDouble:lng],
                         str
                         ];
    NSArray *keys = @[
                      @"chat_room_lat",
                      @"chat_room_lng",
                      @"userEmail"
                      ];
    
    [appDelegate sendDataHttp:objects keyForDic:keys urlString:URL_FOR_ROOM_LIST setDelegate:self];
    
    
    /////////////////////////////조인드 리스트는 응답없고, 위에 토탈 리스트는 조인안된애들은 안불러와야하는게 맞당
    
    //joined list
    
    objects = @[
                str
                ];
    keys = @[
             @"member_email"
             
             ];
    
    
    [appDelegate sendDataHttp:objects keyForDic:keys urlString:URL_FOR_ROOM_MYLIST setDelegate:self];
    
//    [chatRoomListTableView reloadData];
}
- (IBAction)makeRoom:(id)sender {
    JPMakeChatRoomViewController *makeChatRoomViewController = [[JPMakeChatRoomViewController alloc] initWithNibName:@"JPMakeChatRoomViewController" bundle:nil];
    [self.navigationController pushViewController:makeChatRoomViewController animated:YES];

}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
//    NSLog(@"------------------------------------------------------------------------------");
//    NSLog(@"cur pos : %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    
//    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
//    NSNumber *lng = [NSNumber numberWithDouble:location.coordinate.longitude];
    double lat = location.coordinate.latitude;
    double lng = location.coordinate.longitude;
    
    
    
//    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"currentLocation"];
//    [[NSUserDefaults standardUserDefaults] setObject:lat forKey:@"CL_Lat"];
//    [[NSUserDefaults standardUserDefaults] setObject:lng forKey:@"CL_Lng"];

    [[NSUserDefaults standardUserDefaults] setDouble:lat forKey:@"CL_lat"];
    [[NSUserDefaults standardUserDefaults] setDouble:lng forKey:@"CL_lng"];
    
//    NSArray *arrLocation = [[NSArray alloc] initWithObjects:location, nil];
//    [[NSUserDefaults standardUserDefaults] setObject:arrLocation forKey:@"currentLocation"];

    NSNumber *mlLat = [NSNumber numberWithDouble:lat];
    NSNumber *mlLng = [NSNumber numberWithDouble:lng];
    NSArray *dataArr = @[
                         mlLat,
                         mlLng,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         ];
    NSArray *keyArr = @[
                        @"ml_latitude",
                        @"ml_longitude",
                        @"ml_m_id"
                        ];

    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_UPDATE_LOCATION setDelegate:self];
    
    tempLabel.text = [NSString stringWithFormat:@"cur pos : %f, %f", location.coordinate.latitude, location.coordinate.longitude];
}


#pragma mark - Conn delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];

    //채팅방 리스트
    if ([responseType  isEqual: @"ChatRoom List"]) {
        NSLog(@"채팅방리스트 성공");
        
        
        //temporary....
        [chatRoomListArray removeAllObjects];
        numOfChatRooms = 0;
        
        NSArray *arr = [dic objectForKey:@"data"];
        
        for (NSDictionary *item in arr) {
            if ([[item objectForKey:@"has_joined"] intValue] == 0) {
                [chatRoomListArray addObject:item];
                numOfChatRooms++;
            }
        }

        [chatRoomListTableView reloadData];
        
    }
    
    else if ([responseType isEqualToString:@"Create ChatRoom"]) {
        NSLog(@"채팅방 만들기 성공");
    }
    
    else if ([responseType isEqualToString:@"Joining ChatRoom"]) {
        NSLog(@"채팅방 조인하기 성공");
        
//        NSString *crmID = [dic objectForKey:@"crm_id"];
//
//        chattingRoomViewController.crm_id = crmID;
        
//        [self.navigationController pushViewController:chattingRoomViewController animated:YES];

//        joinViewController = [[JPJoinViewController alloc] initWithNibName:@"JPJoinViewController" bundle:nil];
//        joinViewController.chattingRoomViewController = chattingRoomViewController;
//        [self.navigationController pushViewController:joinViewController animated:YES];
        
    }
    
    else if ([responseType isEqualToString:@"My ChatRoom List"]) {
        NSLog(@"내가 조인한 채팅방 리스트 성공");
        
        NSArray *arr = [dic objectForKey:@"data"];
        numOfJoinedRooms = (int)[arr count];
        joinedChatRoomListArray = arr;
        [chatRoomListTableView reloadData];

    }
    
    else if ([responseType isEqualToString:@"ChatRoom Info"]) {
        NSLog(@"채팅방 정보 성공");
    }
    
    else if ([responseType isEqualToString:@"Member List"]) {
        NSLog(@"채팅방 내 조인한 유저들 리스트 성공");
        


    }
    else if ([responseType isEqualToString:@"Get NearMember"]) {
        NSLog(@"Users within 10km");
        nearMembersArray = [dic objectForKey:@"data"];
        [chatRoomListTableView reloadData];        

    }
    else if ([responseType isEqualToString:@"Deactivate ChatRoom Member"]) {
        NSLog(@"채팅방 탈퇴하기 성공");
    }
    
    else if ([responseType isEqualToString:@"Delete ChatRoom"]) {
        NSLog(@"채팅방 지우기 성공");
    }
    
    
    
    else if ([responseType isEqualToString:@"Location Send"]) {
//        NSLog(@"LOCATION UPDATED");
    }
    
    [indicator stopAnimating];

    
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Joined Rooms";
    }
    if (section == 1) {
        return @"Not Joined Rooms";
    }
    if (section == 2) {
        return @"Near Members (<10km)";
    }
    else
        return @"Defaults";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"basic cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = [[nearMembersArray objectAtIndex:indexPath.row] objectForKey:@"member_name"];
    }

    cell.backgroundColor = [UIColor whiteColor];
    //joined
    if (indexPath.section == 0) {
        cell.textLabel.text = [[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"];
        
        NSString *maker = [[[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_maker"] stringValue];
        NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
        NSString *roomName = [[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"];
        NSLog(@"roomname: %@, maker %@ , me %@", roomName, maker, me);
        
        if ([maker isEqualToString:me]) {

            cell.backgroundColor = [UIColor greenColor];
        }
    }

    //not joined
    else if (indexPath.section == 1) {
        NSDictionary *data = [chatRoomListArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [data objectForKey:@"chat_room_name"];
        
//        NSLog(@"%@",[data objectForKey:@"has_joined"]);
        NSNumber *isJoined = [data objectForKey:@"has_joined"];
        
        //join된애들 구분
        if ([isJoined intValue] == 1) {

//            cell.textLabel.backgroundColor = [UIColor redColor];
            cell.backgroundColor = [UIColor redColor];
        }
    }

//    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return numOfJoinedRooms;
    }
    if (section == 1) {
        return numOfChatRooms;
    
    }
    if (section == 2) {
        return [nearMembersArray count];
    }
    return 10;
}


// 선택한 열의 채팅방에
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (indexPath.section == 1) {
        NSLog(@"Total Room");
        
        //조인 안된 방 => 확인할 필요가 없음
        
        //클릭하면 조인뷰로
        joinViewController = [[JPJoinViewController alloc] initWithNibName:@"JPJoinViewController" bundle:nil];
        joinViewController.chattingRoomViewController = chattingRoomViewController;
        joinViewController.crID = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
        
        
        //맵 정보를 받아서 넘겨줌
        
        [self.navigationController pushViewController:joinViewController animated:YES];
//        [self.navigationController presentViewController:joinViewController animated:YES completion:nil];


    }
    else if (indexPath.section == 0) {
        NSLog(@"joined Room");
       
//        // 클릭시 조인되던 소스코드
        NSString *crID = [[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
//        NSLog(@"crid = %@", crID);
        NSString *str = [NSString stringWithFormat:@"%@",crID];
//        NSLog(@"class of crid = %@", [crID class]);
//        NSLog(@"class of str = %@", [str class]);
//        
//        
//        NSArray *dataArr = @[
//                             [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
//                             crID,
//                             [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
//                             [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
//                             ];
//        NSArray *keyArr = @[
//                            @"m_id",
//                            @"cr_id",
//                            @"userName",
//                            @"userPwd",
//                            ];
        
//        [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_ROOM_JOIN setDelegate:self];
        
        chattingRoomViewController = [[JPChattingRoomViewController alloc] initWithNibName:@"JPChattingRoomViewController" bundle:nil];
        chattingRoomViewController.m_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
        chattingRoomViewController.cr_id_room = str;
        chattingRoomViewController.crm_id = [[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"crm_id"];
        chattingRoomViewController.chatRoomTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;


        NSString *myMid = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
        NSString *joinMid = [NSString stringWithFormat:@"%@",[[joinedChatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_maker"]];
//        NSLog(@"%@ = %@", myMid, joinMid);
        
        if ([myMid isEqual:joinMid]) {
            chattingRoomViewController.isOwner = YES;
        }
        else {
            chattingRoomViewController.isOwner = NO;
        }
        
        [self.navigationController pushViewController:chattingRoomViewController animated:YES];
//        NSLog(@"mid = %@, crid = %@", [chattingRoomViewController.m_id class], [chattingRoomViewController.cr_id_room class]);
    }
}


@end
