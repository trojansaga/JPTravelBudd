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

//    [self addObserver:self forKeyPath:@"countOfChattingContents" options:0 context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgReceived) name:@"newMsgArrival" object:nil];
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
    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatRecord" inManagedObjectContext:_mob];
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:NO];
//    
//    [request setSortDescriptors:@[sort]];
//    [request setEntity:entity];
//    chattingContents = [[_mob executeFetchRequest:request error:nil] mutableCopy];

//    self.countOfChattingContents = [chattingContents count];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action) name:@"count" object:nil];
    
    self.tabBarController.tabBar.hidden = YES;
    
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
        
        [chattingTableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [chattingTableView reloadData];
//        chattingTableView.contentOffset = CGPointMake(0, chattingTableView.contentSize.height);
//
//    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

//    [self exitRoom];//????????? 이거 왜한거임 도데체
    
    [self removeKeyboardNotification];

    [chattingContents removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMsgArrival" object:nil];
//    [self removeObserver:self forKeyPath:@"countOfChattingContents"];

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"count" object:chattingContents];
    
    self.tabBarController.tabBar.hidden = NO;
    
}


#pragma mark - Action

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
//    NSLog(@"action");
    [self refreshChattingContents];
    
    
}

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"observed");
//    if ([keyPath isEqual:@"countOfChattingContents"]) {
//        [chattingTableView reloadData];
//    }
//}

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

- (void)removeKeyboardNotification
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
    [self resignKeyboard];

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
            //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell = [chattingTableView dequeueReusableCellWithIdentifier:kChatContentsCellIDMe];
        }
        
    }
    //others
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kChatContentsCellID];
        if (cell == nil) {
            [chattingTableView registerNib:[UINib nibWithNibName:@"JPChatContentCellTableViewCell" bundle:nil] forCellReuseIdentifier:kChatContentsCellID];
            //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell = [chattingTableView dequeueReusableCellWithIdentifier:kChatContentsCellID];
        }
        
    }
    
    
//    cell.textLabel.text = [[chattingContents objectAtIndex:indexPath.row] body];

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

//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"------------------------------------------------------------------------------");
//    NSLog(@"endedit");
//}

#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];
    
//    NSLog(@"response : %@", responseType);
    
    
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
    
    else {

        //얘는 리턴이 그냥 스트링
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        
        if ([str isEqualToString:@"Sending Success"]) {
            NSLog(@"send success");
            NSLog(@"------------------------------------------------------------------------------");
            
            NSString *body = sendedString;
            NSString *fromWho = nickName;
//            NSString *fromWho = @"mem";
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
            
            //ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ 몰라젠장 일단 실행부터, 아마도 presence - unavailable나는게 문제같은데, 일딴 땜빵 ㄱ
            [self exitRoom];
            [self enterRoom];
            
            [self refreshChattingContents];

            
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

@end
