//
//  JPChatViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChatViewController.h"

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
//    [self sendHttpChatRooms];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppJID"];
    NSArray *objects = @[str];
    NSArray *keys = @[@"member_email"];
    NSString *url = @"http://54.199.143.8:8080/TravelBudd/ChatRoom/List";
    [self sendDataHttp:objects keyForDic:keys urlString:url];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Func
-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];

    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (IBAction)reloadTableView:(id)sender {
    [chatRoomListTableView reloadData];
}
- (IBAction)makeRoom:(id)sender {
  
//    NSURL *urlForLogin = [NSURL URLWithString:@"http://54.199.143.8:8080/TravelBudd/Member/Login"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlForLogin];
//    
//    
//    NSDictionary *dic = [NSDictionary
//                         dictionaryWithObjectsAndKeys:
//                         @"dd",@"member_email",
//                         @"g",@"member_password", nil];
//    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:data];
//    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    [conn start];

}

- (void) sendHttpChatRooms {
    
    NSString *xmppJID = [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppJID"];
    NSURL *urlForLogin = [NSURL URLWithString:@"http://54.199.143.8:8080/TravelBudd/ChatRoom/List"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlForLogin];
    
    NSDictionary *dic = [NSDictionary
                         dictionaryWithObjectsAndKeys:
                         xmppJID,@"member_email", nil];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [conn start];
}

#pragma mark - Conn delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"//Response received");
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"채팅방 리스트 출력");
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    //    NSString *str = [dic objectForKey:@"message"];
//    NSLog(@"//Data received : %@",str);
    
    //채팅방 리프레시
    numOfChatRooms = [arr count];
    NSLog(@"arr count = %i", numOfChatRooms);
    if (numOfChatRooms == 0) {
        NSLog(@"cr_id: %@", [dic objectForKey:@"cr_id"]);
    }
    else {
        chatRoomListArray = arr;
        [chatRoomListTableView reloadData];
    }
    
//    if ([str isEqualToString:@"success"]) {
//        NSString *m_id = [dic objectForKey:@"m_id"];
//        [[NSUserDefaults standardUserDefaults] setObject:m_id forKey:@"m_id"];
//        
//    }
//    else {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Login Denied"
//                                  message:@"try again" delegate:self
//                                  cancelButtonTitle:@"ok"
//                                  otherButtonTitles:nil, nil];
//        
//        [alertView show];
//    }

    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *mID = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
    NSLog(@"mid = %@", mID);
    NSString *str = [NSString stringWithFormat:@"%@",mID];
    NSLog(@"class of mid = %@", [mID class]);
    NSLog(@"class of str = %@", [str class]);
    
//    NSString *urlStr = @"http://54.199.143.8:8080/TravelBudd/ChatRoom/RoomNo/";
    NSString *urlStr = @"http://54.199.143.8:8080/TravelBudd/ChatRoom/MemberList/";

    
    

    NSLog(@"url = %@", urlStr);
    
    NSString *finalUrlStr = [urlStr stringByAppendingString:str];
    NSLog(@"click %@",finalUrlStr);
    
//    NSLog(@"click %@",urlStr);
    [self sendDataHttp:nil keyForDic:nil urlString:finalUrlStr];
    
//    - 채팅방 정보
//    
//    URL(POST) : 54.199.143.8:8080/TravelBudd/ChatRoom/RoomNo/채팅방 번호(cr_id)
//    
//    파라미터(JSON) : 없음. URL 뒤에 채팅방 cr_id를 붙이면 됨
//    
//    결과 값 : {
//    chat_room_city: 채팅방의 도시,
//    chat_room_create_date: 방이 만들어진 시간 timestamp,
//    chat_room_description: 방설명,
//    chat_room_is_close: 비밀방 여부,
//    chat_room_lat: latitude,
//    chat_room_lng: longitude,
//    chat_room_maker: 방 만든이 m_id,
//    chat_room_name: 방이름,
//    chat_room_no_of_people: 방 최대 인원수,
//    chat_room_valid_date: 방 만기일,
//    cr_id: 방 id,
//    has_joined: 유저의 방 가입여부,
//    userEmail: 유저 이메일(이건 상관없음, 평소엔 그냥 null 값임)
//    }


}


@end
