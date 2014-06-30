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
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationItem.title = @"Chatting";

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
    NSLog(@"mid = %@, crid = %@", [chattingRoomViewController.m_id class], [chattingRoomViewController.cr_id_room class]);
    

//    //조인멤버 확인,
//    NSString *urlStr = URL_FOR_ROOM_JOINEDMEMBER_LIST_WITHOUT_CRID;
//    urlStr = [urlStr stringByAppendingString:str];
//    NSLog(@"%@",urlStr);
//    [jpConnectionDelegate sendDataHttp:nil keyForDic:nil urlString:urlStr setDelegate:self];

}


@end
