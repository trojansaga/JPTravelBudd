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

    
//    //커넥션 담당 오브젝트
//    jpConnectionDelegate = [[JPConnectionDelegateObject alloc] init];
//    jpConnectionDelegate.delegate = self;
    

    //auto login
    [self login:nil];

    


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)login:(id)sender {

    NSString *domain = @"@54.199.143.8";
    NSString *xmppJID = [textFieldForID.text stringByAppendingString:domain];

    [[NSUserDefaults standardUserDefaults] setObject:textFieldForID.text forKey:@"ID"];
    [[NSUserDefaults standardUserDefaults] setObject:xmppJID forKey:@"XMPPJID"];
    [[NSUserDefaults standardUserDefaults] setObject:textFieldForPW.text forKey:@"PASSWORD"];
    
    NSArray *dataArr = @[
                         xmppJID,
                         textFieldForPW.text
                         ];
    
    NSArray *keyArr = @[
                        @"member_email",
                        @"member_password"
                        ];
    
    
    JPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_LOGIN setDelegate:self];

}
- (IBAction)joinUs:(id)sender {

    joinUsView.hidden = NO;
    

}
- (IBAction)join:(id)sender {

    joinUsView.hidden = YES;
    
    NSString *domain = @"@54.199.143.8";
    NSString *xmppJID = [textFieldForJoinUsID.text stringByAppendingString:domain];

//    NSLog(@"%@",xmppJID);
    
    NSArray *dataArr = @[
                         xmppJID,
                         textFieldForJoinUsPW.text,
                         textFieldForJoinUsID.text
                         ];
    
    NSArray *keyArr = @[
                        @"member_email",
                        @"member_password",
                        @"member_name"
                        ];

    JPAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_MEMBER_JOIN setDelegate:self];
}

#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"//Response received");
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString* responseType = [dic objectForKey:@"data_type"];
    NSLog(@"responseType = %@",responseType);

    //response type 안나옴....
    if ([responseType isEqualToString:@"Login"]) {
        NSLog(@"로그인 하기");
        
        NSString *str = [dic objectForKey:@"message"];
        NSLog(@"//Data received : %@",str);
        
        if ([str isEqualToString:@"success"]) {
            NSString *m_id = [dic objectForKey:@"m_id"];
            NSLog(@"login success");
            [[NSUserDefaults standardUserDefaults] setObject:m_id forKey:@"M_ID"];
            
            JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate connect];
            //원래는 jid 체크를 한번 더 해야하지만 서버에서 success를 리턴할 경우 서버에서 체크한 것으로 간주
            
            JPTabbarController *tabbarController = [[JPTabbarController alloc] initWithNibName:@"JPTabbarController" bundle:nil];

            [self presentViewController:tabbarController animated:YES completion:nil];
        }
        
        else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Login Denied"
                                      message:@"check ID or PW, try again" delegate:self
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }
    
    // 회원가입이랑 로그인이랑 타입이 같음
    else if ([responseType isEqualToString:@"Joining"]) {
        NSLog(@"회원가입하기");
        if ([[dic objectForKey:@"message"] isEqualToString:@"success"]) {
            NSLog(@"joining success");
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Join Denied"
                                      message:@"try again" delegate:self
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
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

@end
