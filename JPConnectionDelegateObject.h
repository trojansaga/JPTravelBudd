//
//  JPConnectionDelegateObject.h
//  TravelBudd
//
//  Created by MC on 2014. 5. 6..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPConnectionDelegateObject : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>

- (void) sendHttp:(NSString*)url httpType:(NSString*)str;
@end
