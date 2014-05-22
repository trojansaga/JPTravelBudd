//
//  JPConnectionDelegateObject.m
//  TravelBudd
//
//  Created by MC on 2014. 5. 6..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPConnectionDelegateObject.h"


@implementation JPConnectionDelegateObject


-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr setDelegate:(id)instance {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:instance];
    [conn start];

}





@end
