//
//  JPAppDelegate.m
//  TravelBudd
//
//  Created by MC on 2014. 4. 3..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import <CFNetwork/CFNetwork.h>

#import "JPAppDelegate.h"
#import "JPLoginViewController.h"

#import "ChatRecord.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
//static const int ddLogLevel = LOG_LEVEL_VERBOSE;
static const int ddLogLevel = LOG_LEVEL_OFF;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;

#endif


@implementation JPAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"Remote Notification Received: %@", userInfo);
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.alertBody = @"message to be displayed";
//    notification.applicationIconBadgeNumber = 1;
//    
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    completionHandler(UIBackgroundFetchResultNewData);
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    if (launchOptions != nil)
//	{
//		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//		if (dictionary != nil)
//		{
//			NSLog(@"Launched from push notification: %@", dictionary);
//		}
//	}
    
    NSLog(@"--------------------------------------------------");
//    if (launchOptions != nil)
//	{
//		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//		if (dictionary != nil)
//		{
//			NSLog(@"Launched from push notification: %@", dictionary);
//		}
//	}

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self setupStream];
    
    JPLoginViewController *loginViewController = [[JPLoginViewController alloc] initWithNibName:@"JPLoginViewController" bundle:nil];
    self.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
   
    
    
    //APNS
    NSDictionary *userInfo = [launchOptions objectForKey:
                              UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(userInfo != nil)
    {
        [self application:application didFinishLaunchingWithOptions:userInfo];
    }
    
    NSLog(@"APNS REGISTER");
    // APNS에 디바이스를 등록한다.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeSound];

    return YES;
}

-(void)dealloc {
    [self teardownStream];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"resign active");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"enter background");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"enter foreground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"become active");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"terminated");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - APNS

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    NSLog(@"APNS Device Token: %@", deviceId);
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"deviceId"];
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"APNS FAILED");
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"instead this method, %@", userInfo);
    
    NSString *displayName = [userInfo objectForKey:@"from"];
    NSString *body = [userInfo objectForKey:@"msg"];
    NSString *where = [userInfo objectForKey:@"cr_id"];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertAction = @"Ok";
    localNotification.alertBody = [NSString stringWithFormat:@"%@:%@",displayName,body];
    localNotification.applicationIconBadgeNumber = 0;

    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

    ChatRecord *record = [NSEntityDescription insertNewObjectForEntityForName:@"ChatRecord" inManagedObjectContext:_managedObjectContext];
    [record setBody:body];
    [record setFromWho:displayName];
    [record setFromWhere:where];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy.MM.dd.HH.mm.ss";
    NSString *date = [formatter stringFromDate:[NSDate date]];
    
    [record setTimeStamp:date];
    
    
    NSLog(@"body = %@", body);
    NSLog(@"where = %@", where);
    NSLog(@"who = %@", displayName);
    NSLog(@"date = %@", date);
    
    [_managedObjectContext save:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newMsgArrival" object:nil];
//    completionHandler(UIBackgroundFetchResultNewData);
    completionHandler(UIBackgroundFetchResultNoData);
    
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    completionHandler(UIBackgroundFetchResultNewData);

//    {“msg” : “메시지" , “cr_id” : “메시지를 보낸 방 이름", “from” : “메시지를 보낸사람"}
    
//    NSString *string = [NSString stringWithFormat:@"%@", userInfo];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
////                                                    message:string delegate:nil
//                                                    message:@"msg received" delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    NSString *displayName = [userInfo objectForKey:@"from"];
    NSString *body = [userInfo objectForKey:@"msg"];
    NSString *where = [userInfo objectForKey:@"cr_id"];

    NSLog(@"%li", [[UIApplication sharedApplication] applicationState]);
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        NSLog(@"active");
        
     NSLog(@"name : %@ , body : %@", displayName, body);
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                         message:body
                                                        delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
     [alertView show];

//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"Ok";
//        localNotification.alertBody = [NSString stringWithFormat:@"%@,%@",displayName,body];
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        

        ChatRecord *record = [NSEntityDescription insertNewObjectForEntityForName:@"ChatRecord" inManagedObjectContext:_managedObjectContext];
        [record setBody:body];
        [record setFromWho:displayName];
        [record setFromWhere:where];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy.MM.dd.HH.mm.ss";
        NSString *date = [formatter stringFromDate:[NSDate date]];
        
        [record setTimeStamp:date];
        
        
        NSLog(@"body = %@", body);
        NSLog(@"where = %@", where);
        NSLog(@"who = %@", displayName);
        NSLog(@"date = %@", date);
        
        [_managedObjectContext save:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newMsgArrival" object:nil];
        
        
    }
    else
    {
        NSLog(@"non-active");        
//        // We are not active, so use a local notification instead
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"Ok";
//        localNotification.alertBody = [NSString stringWithFormat:@"%@,%@",displayName,body];
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
    
    
    
}


#pragma mark Private

- (void)setupStream {
    _xmppStream = [[XMPPStream alloc] init];
    _xmppReconnect = [[XMPPReconnect alloc] init];
    
    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
    
    _xmppRoster.autoFetchRoster = YES;
	_xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];
    
    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;

    [_xmppReconnect     activate:_xmppStream];
    [_xmppRoster        activate:_xmppStream];
    [_xmppCapabilities  activate:_xmppStream];

    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;

}
- (void)teardownStream {
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
    
    [_xmppReconnect     deactivate];
    [_xmppRoster        deactivate];
    [_xmppCapabilities  deactivate];
    
    [_xmppStream disconnect];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRoster = nil;
    _xmppRosterStorage = nil;
    _xmppCapabilities = nil;
	_xmppCapabilitiesStorage = nil;
}

- (void)goOnline {
    NSLog(@"online");
    XMPPPresence *presence = [XMPPPresence presence];
    NSString *domain = [_xmppStream.myJID domain];
    if ([domain isEqualToString:@"54.199.143.8"]) {
        NSLog(@"DOMAIN : 54.199.143.8");
    }
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![_xmppStream isDisconnected]) {

		return YES;
	}
    
    // JID = userName@domain
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"XMPPJID"];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"PASSWORD"];


	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";

//    NSLog(@"%@,%@",myJID,myPassword);
    
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[_xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
	NSError *error = nil;
	if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{

		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[_xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [_xmppRosterStorage mainThreadManagedObjectContext];
}

//- (NSManagedObjectContext *)managedObjectContext_capabilities
//{
//	return [_xmppCapabilitiesStorage mainThreadManagedObjectContext];
//}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TravelBudd.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Http Connection

-(void)sendDataHttp:(NSArray *)objects keyForDic:(NSArray *)keys urlString:(NSString *)urlStr setDelegate:(id)instance {
    
//    NSLog(@"urlStr = %@", urlStr);
    
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}



- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

	//제거
    
//	if (allowSelfSignedCertificates)
//	{
//		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
//	}
//	
//	if (allowSSLHostNameMismatch)
//	{
//		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
//	}
//	else
//	{
//		NSString *expectedCertName = [xmppStream.myJID domain];
//        
//		if (expectedCertName)
//		{
//			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
//		}
//	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = NO;
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    

    // standard msg = group msg
	if ([message isGroupChatMessage]) {
//        NSLog(@"------------------------------------------------------------------------------");
        // eg. 85@conference.54.199.143.8
        // eg. 85@conference.54.199.143.8/id
        NSString *displayName = [message fromStr];
        NSArray *strArr = [displayName componentsSeparatedByString:@"@"];
        NSString *fromWhere = [strArr objectAtIndex:0];
        NSRange range = [displayName rangeOfString:@"/"];

        NSString *fromWho;
        if (range.length != 0) {
            strArr = [displayName componentsSeparatedByString:@"/"];
            fromWho = [strArr lastObject];
        }
        else {
            fromWho = @"room";
            NSLog(@"------------------------------------------------------------------------------");            
            NSLog(@"room msg received!");
            //temp - 자꾸 방이주는 정보는 중첩됨, 무시 ㄱ
            return ;
        }
        
        NSString *body = [message body];
        
//        NSLog(@"name : %@ , body : %@", displayName, body);
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                            message:body
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
        
        ChatRecord *record = [NSEntityDescription insertNewObjectForEntityForName:@"ChatRecord" inManagedObjectContext:_managedObjectContext];
        [record setBody:body];
        [record setFromWho:fromWho];
        [record setFromWhere:fromWhere];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy.MM.dd.HH.mm.ss";
        NSString *date = [formatter stringFromDate:[NSDate date]];
        
        [record setTimeStamp:date];

        
        NSLog(@"body = %@", body);
        NSLog(@"where = %@", fromWhere);
        NSLog(@"who = %@", fromWho);
        NSLog(@"date = %@", date);
        
        [_managedObjectContext save:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newMsgArrival" object:nil];
//        NSLog(@"------------------------------------------------------------------------------");

    }
    
    
    // not ordinary
    
	if ([message isChatMessageWithBody])
	{
        /*
		XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:_xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
//		NSString *displayName = [user displayName];
        NSString *displayName = [message fromStr];

        
		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
		{
            
          			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
          															  message:body
          															 delegate:nil
          													cancelButtonTitle:@"Ok"
          													otherButtonTitles:nil];
          			[alertView show];
            
            
            
		}
		else
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"%@,%@",displayName,body];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
         
         */
        
        
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        //		NSString *displayName = [user displayName];
        NSString *displayName = [message fromStr];

//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"Ok";
//        localNotification.alertBody = [NSString stringWithFormat:@"%@,%@",displayName,body];
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            
        }
        else {
            
        }
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}


@end
