//
//  JPJoinViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 9. 26..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPJoinViewController.h"

#import "JPChatViewController.h"
#import "PinRecord.h"
#import "JPChattingRoomMapViewController.h"

@interface JPJoinViewController ()

@end

@implementation JPJoinViewController

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
    UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(join)];
    self.navigationItem.rightBarButtonItem = joinButton;
    
    
//    //mapview = loaded mapview
    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    _mob = [appDelegate managedObjectContext];
    
    //map connection    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",URL_FOR_RETREIVE_MAPDATA_WITHOUT_ROOMID, _crID];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    //    [request setHTTPBody:data];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    //mapview
    _chattingRoomViewController = [[JPChattingRoomMapViewController alloc] initWithNibName:@"JPChattingRoomMapViewController" bundle:nil];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)retrieveDataFromPrevious:(id)sender {
    JPChatViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];

}

- (void) join {
    
    // 클릭시 조인되던 소스코드
//    NSString *crID = [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"cr_id"];
//    NSLog(@"crid = %@", crID);
    NSString *str = [NSString stringWithFormat:@"%@",_crID];
//    NSLog(@"class of crid = %@", [crID class]);
//    NSLog(@"class of str = %@", [str class]);
    
    
    NSArray *dataArr = @[
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"],
                         _crID,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"ID"],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"],
                         ];
    NSArray *keyArr = @[
                        @"m_id",
                        @"cr_id",
                        @"userName",
                        @"userPwd",
                        ];
//    JPChatViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 2];

    JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendDataHttp:dataArr keyForDic:keyArr urlString:URL_FOR_ROOM_JOIN setDelegate:self];
    
//    chattingRoomViewController = [[JPChattingRoomViewController alloc] initWithNibName:@"JPChattingRoomViewController" bundle:nil];
//    chattingRoomViewController.m_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"M_ID"];
//    chattingRoomViewController.cr_id_room = str;
//    chattingRoomViewController.chatRoomTitle = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    //    [[chatRoomListArray objectAtIndex:indexPath.row] objectForKey:@"chat_room_name"]; //this? or not?
    
//    NSLog(@"mid = %@, crid = %@", [chattingRoomViewController.m_id class], [chattingRoomViewController.cr_id_room class]);

    
    
//    [self.navigationController pushViewController:_chattingRoomViewController animated:YES];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *responseType = [dic objectForKey:@"data_type"];
    
    
    if ([responseType isEqualToString:@"Joining ChatRoom"]) {
        NSLog(@"채팅방 조인하기 성공");
        
        //        NSString *crmID = [dic objectForKey:@"crm_id"];
        //
        //        chattingRoomViewController.crm_id = crmID;
        
        //        [self.navigationController pushViewController:chattingRoomViewController animated:YES];
        
        //        joinViewController = [[JPJoinViewController alloc] initWithNibName:@"JPJoinViewController" bundle:nil];
        //        joinViewController.chattingRoomViewController = chattingRoomViewController;
        //        [self.navigationController pushViewController:joinViewController animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //map data received
    else if ([responseType isEqualToString:@"GetMap"]) {
        NSLog(@"//Map data received//");
        
        NSDictionary *mapDataDic = [dic objectForKey:@"data"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-DD hh:mm:ss";
        //add map data
        //////////
        _mapData = [NSEntityDescription insertNewObjectForEntityForName:@"MapRecord" inManagedObjectContext:_mob];
        _mapData.m_FinishDate = [dateFormatter dateFromString:[mapDataDic objectForKey:@"m_FinishDateStr"]];
        _mapData.m_StartDate = [dateFormatter dateFromString:[mapDataDic objectForKey:@"m_StartDateStr"]];
        _mapData.m_MapTitle = [mapDataDic objectForKey:@"m_MapTitle"];
        _mapData.m_SavedLatitude = [mapDataDic objectForKey:@"m_SavedLatitude"];
        _mapData.m_SavedLatitudeDelta = [mapDataDic objectForKey:@"SavedLatitudeDelta"];
        _mapData.m_SavedLongitude = [mapDataDic objectForKey:@"m_SavedLongitude"];
        _mapData.m_SavedLongitudeDelta = [mapDataDic objectForKey:@"SavedLongitudeDelta"];
        _mapData.m_TotalBudget = [mapDataDic objectForKey:@"m_TotalBudget"];
        
        NSArray *pinsDataArr = [mapDataDic objectForKey:@"pins"];
        for (NSDictionary *dic in pinsDataArr) {
            //add pin annotation
            /////////////////
            //        _roomMapView addpin!!!!!
            //        _roomMapView addAnnotation:
            PinRecord *pin = [NSEntityDescription insertNewObjectForEntityForName:@"PinRecord" inManagedObjectContext:_mob];
            pin.p_Budget = [dic objectForKey:@"p_Budget"];
            pin.p_Description = [dic objectForKey:@"p_Description"];
            pin.p_FinishDate = [dateFormatter dateFromString:[dic objectForKey:@"p_FinishDateStr"]];
            //            pin.p_StartDate = [dateFormatter dateFromString:[dic objectForKey:@""]]//no start date
            pin.p_Latitude = [dic objectForKey:@"p_Latitude"];
            pin.p_Longitude =[dic objectForKey:@"p_Longitude"];
            pin.p_Order = [dic objectForKey:@"p_Order"];
            [_mapData addPinsObject:pin];
        }
        

        _chattingRoomViewController.mapData = _mapData;
//        [_chattingRoomViewController refreshMap];
        [_chattingRoomViewController refreshMap];
        


        

        
//        [_mob rollback];
    }
    
}

@end
