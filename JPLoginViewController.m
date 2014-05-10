//
//  JPLoginViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 3..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPLoginViewController.h"
#import "JPAppDelegate.h"
#import "JPTabbarController.h"

@interface JPLoginViewController ()

@end

@implementation JPLoginViewController

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
    
    [self.view addSubview:joinUsView];
    joinUsView.hidden = YES;

    //auto login
    [self login:nil];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  [{"m_id":52,"member_email":"testIOS@test.com","member_password":"1234","member_name":"TESTER_IOS","member_join_date":1396416809000},
//  web  server :   "m_id":1,"member_email":"test@test.com","member_password":"1234","member_name":"테스터","member_join_date":1392559681000
//  xmpp server :   Username : b, password : asdf, name : a

- (IBAction)login:(id)sender {

//    NSString *tempStr = [textFieldForID.text stringByAppendingString:@"@test.com"];
//    NSLog(tempStr);
    [[NSUserDefaults standardUserDefaults] setObject:textFieldForID.text forKey:@"xmppJID"];
    [[NSUserDefaults standardUserDefaults] setObject:textFieldForPW.text forKey:@"xmppPASSWORD"];

    NSDictionary *dic = [NSDictionary
                         dictionaryWithObjectsAndKeys:
                         textFieldForID.text,@"member_email",
                         textFieldForPW.text,@"member_password", nil];
    
    //아래부분은 원래 코드.... 왜 app delegate로 이전하면 안될까?? -> setdelegate:self 때문에 안됨
    NSString *urlStr = @"http://54.199.143.8:8080/TravelBudd/Member/Login";
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];

}
- (IBAction)joinUs:(id)sender {
//    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate disconnect];

    joinUsView.hidden = NO;
    

}
- (IBAction)join:(id)sender {

    joinUsView.hidden = YES;
    
    NSDictionary *dic = [NSDictionary
                         dictionaryWithObjectsAndKeys:
                         textFieldForJoinUsID.text,@"member_email",
                         textFieldForJoinUsName.text,@"member_name",
                         textFieldForJoinUsPW.text,@"member_password", nil];
    
    NSString *urlStr = @"http://54.199.143.8:8080/TravelBudd/Member/Join";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];

}

#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"//Response received");
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!login delegate");
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString* responseType = [dic objectForKey:@"data_type"];
    NSLog(@"responseType = %@",responseType);

    //response type 안나옴....
    if (![responseType isEqualToString:@"Joining Member"]) {
        NSLog(@"로그인 하기");
        
        NSString *str = [dic objectForKey:@"message"];
        NSLog(@"//Data received : %@",str);
        
        if ([str isEqualToString:@"success"]) {
            NSString *m_id = [dic objectForKey:@"m_id"];
            [[NSUserDefaults standardUserDefaults] setObject:m_id forKey:@"m_id"];
            
            JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate connect];
            //원래는 jid 체크를 한번 더 해야하지만 서버에서 success를 리턴할 경우 서버에서 체크한 것으로 간주
            
            JPTabbarController *tabbarController = [[JPTabbarController alloc] initWithNibName:@"JPTabbarController" bundle:nil];
            [self presentViewController:tabbarController animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Login Denied"
                                      message:@"try again" delegate:self
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }
    
    // 회원가입이랑 로그인이랑 타입이 같음
    if ([responseType isEqualToString:@"Joining Member"]) {
        NSLog(@"회원가입하기");
    }
}

@end
