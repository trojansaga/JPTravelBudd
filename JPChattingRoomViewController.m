//
//  JPChattingRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChattingRoomViewController.h"

#import "JPAppDelegate.h"


@interface JPChattingRoomViewController ()

@end

@implementation JPChattingRoomViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self enterRoom];

    
    _mob = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatRecord" inManagedObjectContext:_mob];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
    
    [request setSortDescriptors:@[sort]];
    [request setEntity:entity];
    chattingContents = [[_mob executeFetchRequest:request error:nil] mutableCopy];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self exitRoom];
    [self _removeKeyboardNotification];
    
}

#pragma mark - UI

- (void) resignKeyboard {
    [textFieldForMessage resignFirstResponder];
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

- (void)_removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - Room


- (IBAction)showJoinedMember:(id)sender {

    NSLog(@"members =");
    NSDictionary *dic;
    for (dic in self.joinedMemberListArray) {
        NSLog(@"%@\n",[dic objectForKey:@"member_email"]);
    }
}

- (IBAction)deleteRoom:(id)sender {
    
    NSArray *data = @[_cr_id_room];
    NSArray *key = @[@"cr_id"];
    [appDelegate sendDataHttp:data keyForDic:key urlString:URL_FOR_ROOM_DELETE setDelegate:self];
    
}

- (IBAction)leaveRoom:(id)sender {
    NSArray *data = @[_cr_id_room];
    NSArray *key = @[@"cr_id"];
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

- (IBAction)sendMessage:(id)sender {
    NSArray *dataArr = @[
                         textFieldForMessage.text,
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
    NSLog(@"%@",_cr_id_room);
    
    NSString *from = [nickName stringByAppendingString:domain];
    NSString *to = [_cr_id_room stringByAppendingString:conferenceDomain];
    
    
    [presence addAttributeWithName:@"from" stringValue:from];
    [presence addAttributeWithName:@"to" stringValue:to];
    [[appDelegate xmppStream] sendElement:presence];
}

- (void) exitRoom {
    
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];

    NSLog(@"%@",_cr_id_room);
    NSString *from = [nickName stringByAppendingString:domain];
    NSString *to = [_cr_id_room stringByAppendingString:conferenceDomain];
    
    
    [presence addAttributeWithName:@"from" stringValue:from];
    [presence addAttributeWithName:@"to" stringValue:to];
    [presence addAttributeWithName:@"type" stringValue:@"unavailable"];
    [[appDelegate xmppStream] sendElement:presence];
    
}

#pragma mark - TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"basic cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[chattingContents objectAtIndex:indexPath.row] body];


    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chattingContents count];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}
#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];
    
    //채팅방 리스트
    if ([responseType isEqualToString:@"Delete ChatRoom"]) {
        NSLog(@"//채팅방 지우기//");
        
        NSLog(@"%@", [dic objectForKey:@"message"]);
    }
    else if([responseType isEqualToString:@"Deactivate ChatRoom Member"]) {
        NSLog(@"//채팅방 탈퇴하기//");
        
        NSLog(@"%@", [dic objectForKey:@"message"]);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([responseType isEqualToString:@"ChatRoom info"]) {
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
    
    else {

        //얘는 리턴이 그냥 스트링
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        if ([str isEqualToString:@"Sending Success"]) {
            NSLog(@"send success");
            
            
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

@end
