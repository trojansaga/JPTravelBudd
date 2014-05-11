//
//  JPConnectionDelegateObject.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 6..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPDefs.h"

@protocol JPConnectionDelegate <NSObject>

-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr;

@end

@interface JPConnectionDelegateObject : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate> {
    
}

@property (nonatomic, strong) id <JPConnectionDelegate> delegate;

-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr setDelegate:(id)delegate;

@end
