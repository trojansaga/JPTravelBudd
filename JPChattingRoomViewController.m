//
//  JPChattingRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPChattingRoomViewController.h"
#import "JPConnectionDelegateObject.h"


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
    NSArray *dataArr = @[
                         @"Message",
                         textFieldForMessage.text,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppPASSWORD"],
                         @"testcom@54.199.143.8",
                         @"testcom",
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                         ];
    NSArray *keyArr = @[
                        @"data_type",
                        @"message",
                        @"password",
                        @"receiverJID",
                        @"receiverName",
                        @"userName"
                        ];
    JPConnectionDelegateObject *object = [[JPConnectionDelegateObject alloc] init];
    [object sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_MESSAGE setDelegate:self];

    
}

#pragma mark - Private Func


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
