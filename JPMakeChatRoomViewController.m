//
//  JPMakeChatRoomViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 10..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMakeChatRoomViewController.h"
#import "JPChatViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createRoom:(id)sender {
    NSArray *keyArr = @[
                        @"chat_room_maker",
                        @"chat_room_name",
                        @"chat_room_description",
                        @"chat_room_lng",
                        @"chat_room_lat",
                        @"chat_room_is_close",
                        @"chat_room_no_of_people",
                        ];
    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"m_id"],
                         textFieldForRoomName.text,
                         textFieldForRoomDesc.text,
                         @"0.0",
                         @"0.0",
                         @"false",
                         textFieldForRoomMaxNum.text
                         ];
    NSString *urlStr = @"http://54.199.143.8:8080/TravelBudd/ChatRoom/Create";
    [self.navigationController popViewControllerAnimated:YES];
//    [(JPChatViewController*)[[self.navigationController viewControllers] objectAtIndex:1] sendDataHttp:dataArr keyForDic:keyArr urlString:urlStr];
}

@end
