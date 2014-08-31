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
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"XMPPJID"];
    NSArray *objects = @[str];
    NSArray *keys = @[@"member_email"];
    
    [appDelegate sendDataHttp:objects keyForDic:keys urlString:URL_FOR_ROOM_LIST setDelegate:self];
    
    
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
    

    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    

//    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Func

- (IBAction)reloadTableView:(id)sender {
    [chatRoomListTableView reloadData];
}
- (IBAction)makeRoom:(id)sender {
    JPMakeChatRoomViewController *makeChatRoomViewController = [[JPMakeChatRoomViewController alloc] initWithNibName:@"JPMakeChatRoomViewController" bundle:nil];
    [self.navigationController pushViewController:makeChatRoomViewController animated:YES];

}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"------------------------------------------------------------------------------");
    NSLog(@"cur pos : %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"currentLocation"];
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
        
        NSArray *arr = [dic objectForKey:@"data"];
        numOfChatRooms = (int)[arr count];
        chatRoomListArray = arr;
        [chatRoomListTableView reloadData];
        
    }
    
    else if ([responseType isEqualToString:@"Create ChatRoom"]) {
        NSLog(@"채팅방 만들기 성공");
    }
    
    else if ([responseType isEqualToString:@"Joining ChatRoom"]) {
        NSLog(@"채팅방 조인하기 성공");
        
        NSString *crmID = [dic objectForKey:@"crm_id"];

        chattingRoomViewController.crm_id = crmID;
        
        [self.navigationController pushViewController:chattingRoomViewController animated:YES];

        
        
    }
    
    else if ([responseType isEqualToString:@"My ChatRoom List"]) {
        NSLog(@"내가 조인한 채팅방 리스트 성공");
    }
    
    else if ([responseType isEqualToString:@"ChatRoom Info"]) {
        NSLog(@"채팅방 정보 성공");
    }
    
    else if ([responseType isEqualToString:@"Member List"]) {
        NSLog(@"채팅방 내 조인한 유저들 리스트 성공");
        


    }
    
    else if ([responseType isEqualToString:@"Deactivate ChatRoom Member"]) {
        NSLog(@"채팅방 탈퇴하기 성공");
    }
    
    else if ([responseType isEqualToString:@"Delete ChatRoom"]) {
        NSLog(@"채팅방 지우기 성공");
    }
    
    
    [indicator stopAnimating];

    
}

#pragma mark - TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"basic cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.textLabel.text = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"];
//    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numOfChatRooms;
}


// 선택한 열의 채팅방에 로그인 (= 조인)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *crID = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
    NSLog(@"crid = %@", crID);
    NSString *str = [NSString stringWithFormat:@"%@",crID];
    NSLog(@"class of crid = %@", [crID class]);
    NSLog(@"class of str = %@", [str class]);


    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         crID,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         ];
    NSArray *keyArr = @[
                        @"m_id",
                        @"cr_id",
                        @"userName",
                        @"userPwd",
                        ];
    
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_ROOM_JOIN setDelegate:self];
    
    chattingRoomViewController = [[JPChattingRoomViewController alloc] initWithNibName:@"JPChattingRoomViewController" bundle:nil];
    chattingRoomViewController.m_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
    chattingRoomViewController.cr_id_room = str;
    chattingRoomViewController.chatRoomTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//    [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"]; //this? or not?
    
    NSLog(@"mid = %@, crid = %@", [chattingRoomViewController.m_id class], [chattingRoomViewController.cr_id_room class]);
    

//    //조인멤버 확인,
//    NSString *urlStr = URL_FOR_ROOM_JOINEDMEMBER_LIST_WITHOUT_CRID;
//    urlStr = [urlStr stringByAppendingString:str];
//    NSLog(@"%@",urlStr);
//    [jpConnectionDelegate sendDataHttp:nil keyForDic:nil urlString:urlStr setDelegate:self];

}


@end
