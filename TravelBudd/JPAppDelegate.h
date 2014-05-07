//
//  JPAppDelegate.h
//  TravelBudd
//
//  Created by MC on 2014. 4. 3..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"



@interface JPAppDelegate : UIResponder <UIApplicationDelegate,XMPPStreamDelegate> {

    NSString *password;
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
    BOOL isXmppConnected;

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XMPPStream *xmppStream;
@property (strong, nonatomic) XMPPReconnect *xmppReconnect;
@property (strong, nonatomic) XMPPRoster *xmppRoster;
@property (strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (strong, nonatomic) XMPPCapabilities *xmppCapabilities;
@property (strong, nonatomic) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (BOOL)connect;
- (void)disconnect;

- (void) sendHttp:(NSString*)urlStr data:(NSDictionary *) dic;

@end
