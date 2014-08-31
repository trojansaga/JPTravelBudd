//
//  JPMakeChatRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMakeChatRoomViewController.h"
#import "JPChatViewController.h"


@class CLLocation;

@interface JPMakeChatRoomViewController ()

@end

@implementation JPMakeChatRoomViewController

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
    self.title = @"Make Room";
    
    UIBarButtonItem *btnCreate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(createRoom:)];
    self.navigationItem.rightBarButtonItem = btnCreate;
    
//    textViewForRoomDesc.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:0.9f];
    textViewForRoomDesc.backgroundColor = [UIColor colorWithRed:135.f/255.f green:206.f/255.f blue:255.f/255.f alpha:1.f];
//    textViewForRoomDesc.textColor = [UIColor whiteColor];
//    textFieldForRoomDesc.backgroundColor = [UIColor colorWithRed:49.f/255.f green:68.f/255.f blue:94.f/255.f alpha:1.f];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createRoom:(id)sender {
    NSString *isSectetRoom;
    if (switchForSecret.on) {
        isSectetRoom = @"true";
    }
    else {
        isSectetRoom = @"false";
    }
    
    CLLocation *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentLocation"];
    
    NSArray *keyArr = @[
                        @"chat_room_maker",
                        @"userName",
                        @"userPwd",
                        @"chat_room_name",
                        @"chat_room_description",
                        @"chat_room_lng",
                        @"chat_room_lat",
                        @"chat_room_is_close",
                        @"chat_room_no_of_people",
                        ];
    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         textFieldForRoomName.text,
                         textFieldForRoomDesc.text,
                         [NSString stringWithFormat:@"%f", location.coordinate.longitude],
                         [NSString stringWithFormat:@"%f", location.coordinate.latitude],
                         isSectetRoom,
                         textFieldForRoomMaxNum.text
                         ];
   
    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_CREATE_ROOM setDelegate:self];

}


#pragma mark - connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];

    if ([responseType isEqualToString:@"Create ChatRoom"] && [[dic objectForKey:@"message"] isEqualToString:@"success"]) {
        NSLog(@"채팅방 만들기 success");
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if([responseType isEqualToString:@"fail"]) {
        NSLog(@"채팅방 만들기 fail");
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
