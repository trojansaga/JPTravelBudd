//
//  JPChattingRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChattingRoomViewController.h"
#import "JPConnectionDelegateObject.h"
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
    
    NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:@"testios@54.199.143.8"];
    //    [presence addAttributeWithName:@"id" stringValue:@"78"];
    [presence addAttributeWithName:@"to" stringValue:@"78@conference.54.199.143.8/nick"];
    JPAppDelegate *del = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[del xmppStream] sendElement:presence];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showJoinedMember:(id)sender {

    NSLog(@"members =");
    NSDictionary *dic;
    for (dic in self.joinedMemberListArray) {
        NSLog(@"%@\n",[dic objectForKey:@"member_email"]);
    }
}

- (IBAction)sendMessage:(id)sender {
    //아직 jid, email, server id 통합이 안됨
//    NSArray *dataArr = @[
//                         @"Message",
//                         textFieldForMessage.text,
//                         [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppPASSWORD"],
//                         @"testcom@54.199.143.8",
//                         @"testcom",
//                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
//                         ];
//    NSArray *keyArr = @[
//                        @"data_type",
//                        @"message",
//                        @"password",
//                        @"receiverJID",
//                        @"receiverName",
//                        @"userName"
//                        ];
//    JPConnectionDelegateObject *object = [[JPConnectionDelegateObject alloc] init];
//    [object sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_MESSAGE setDelegate:self];

    [self sendGMessage];
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


- (void) sendGMessage {
    
    NSArray *dataArr = @[
                         textFieldForMessage.text,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppPASSWORD"],
                         @"testios",
                         @"78"
                         
                         ];
    NSArray *keyArr = @[
                        @"message",
                        @"userPwd",
                        @"userName",
                        @"cr_id"
                        ];
    JPConnectionDelegateObject *object = [[JPConnectionDelegateObject alloc] init];
    [object sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_GROUP_MESSAGE setDelegate:self];


}

#pragma mark - 

- (IBAction)clickRefreshButton:(id)sender {
    NSLog(@"button");
    JPAppDelegate *delegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
}


#pragma mark - TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"basic cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"kk";
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}
#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
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

@end
