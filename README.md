#Curio iOS SDK 1.03

[Curio](https://gui-curio.turkcell.com.tr) is Turkcell's mobile analytics system, and this is Curio's Client iOS library. Applications developed for iOS 6.0+ can easily use Curio mobile analytics with this library.

#Quick Startup Guide

You can drag'n drop Curio project file into your project. Additionally you should add the dependencies.

## Dependencies

You should Click on Targets -> Your App Name -> and then the 'Build Phases' tab.

And expand 'Link Binary With Library' and click + sign to add required framework if they are not available.

```
- Foundation.framework
- UIKit.framework
- CoreTelephony.framework
- libsqlite3.dylib 
```

If you don't want to run automated unit tests, then you should remove CurioSDKTests.m, CurioSettingsTest.m and CurioDBTests.m files from compilation by Click on Targets -> Your App Name -> And then the 'Build Phases' tab and expand Compile Sources to remove them by clicking on - sign while mentioned source files selected.

#Configuration

There are two ways to configure CurioSDK.

### Info.plist Configuration

You can just copy'n paste CurioSDK item within sample project's Info.plist or CurioSDKTests-Info.plist contained in CurioSDK.Core tests to your project's Info.plist file and edit parameters as you wish.


**ServerURL:** [Required] Curio server URL, can be obtained from Turkcell. 

**ApiKey:** [Required] Application specific API key, can be obtained from Turkcell.

**TrackingCode:** [Required] Application specific tracking code, can be obtained from Turkcell.

**SessionTimeout:** [Optional] Session timeout in minutes. Default is 30 minutes but it's highly recommended to change this value acording to the nature of your application. Specifiying a correct session timeout value for your application will increase the accuracy of the analytics data.

**PeriodicDispatchEnabled:** [Optional] Periodic dispatch is enabled if true. Default is false.

**DispatchPeriod:** [Optional] If periodic dispatch is enabled, this parameter configures dispatching period in minutes. Deafult is 5 minutes. **Note:** This parameter cannot be greater than session timeout value.

**MaxCachedActivityCount:** [Optional] Max. number of user activity that Curio library will remember when device is not connected to the Internet. Default is 1000. Max. value can be 4000.

**LoggingEnabled:** [Optional] All of the Curio logs will be disabled if this is false. Default is true.

**LogLevel:** [Optional] Contains level of the print-out logs.  0 - Error, 1 - Warning, 2 - Info, 3 - Debug. Default is 0 (Error).

**RegisterForRemoteNotifications:**  If enabled, then Curio SDK will automatically register for remote notifications for types defined in "NotificationTypes" parameter.

**NotificationTypes:** Notification types to register; available values: Sound, Badge, Alert


### Manual Configuration

You can specify CurioSDK parameters whenever you want to start a session on client by invoking startSession function just like below.

```
    [[CurioSDK shared] startSession:@"https://curiotest.turkcell.com.tr/api/v2"
                             apiKey:@"XXXXX"
                       trackingCode:@"XXXXX"
                     sessionTimeout:4
            periodicDispatchEnabled:YES
                     dispatchPeriod:1
            maxCachedActivitiyCount:1000
                     loggingEnabled:YES
                           logLevel:0
     registerForRemoteNotifications:YES
                  notificationTypes:@"Sound,Badge,Alert"
                   appLaunchOptions:launchOptions
     ];

```

## Usage

### Starting a session

You can start a session whenever application starts-up by invoking startSession function within CurioSDK class.

```
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    	    [[CurioSDK shared] startSession:launchOptions];
    	    ...
	}
```

### Starting a screen

You can start a screen by invoking startScreen function within CurioSDK class.

```
	- (void) viewDidAppear:(BOOL)animated {
	    [[CurioSDK shared] startScreen:[self class] title:@"Master view" path:@"Master-view"];
	}

```

### Ending a screen

You can end a screen by invoking startScreen function within CurioSDK class.

```
	- (void) viewDidDisappear:(BOOL)animated {
	    [[CurioSDK shared] endScreen:[self class]];
	}
```

### Sending an event

You can send event-key and value pairs by invoking sendEvent function within CurioSDK class.

```
	- (IBAction)sendEvent:(id)sender {
	    [[CurioSDK shared] sendEvent:@"Clicked button" eventValue:NSStringFromClass([self class])];
	}
	
```


### Ending session

You can end started session by invoking endSession function with CurioSDK class. Normally there is no need to manually end application session. CurioSDK automatically handles session-finish processes to notify Curio Server.

```
	- (void)applicationWillTerminate:(UIApplication *)application {
	    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
	    [[CurioSDK shared] endSession];
	}

```

### Registering for push notifications 

Curio iOS SDK can register your application for remote push notifications automatically if you set "RegisterForRemoteNotifications" parameter true and set "NotificationTypes" parameter. You also have to implement "didReceiveRemoteNotification" and "didRegisterForRemoteNotificationsWithDeviceToken" methods as shown below:

```
	- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
	}

	//or if you implement this method
	- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	    completionHandler(UIBackgroundFetchResultNewData);
    	    [[CurioNotificationManager shared] didReceiveNotification:userInfo];
	}

	- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    	    [[CurioNotificationManager shared] didRegisteredForNotifications:deviceToken];
	}

```



#Internals

Curio SDK consists of two different workflows which maintains storage and submittance functionalities.

First workflow (which we will call storage workflow) handles database records one way to save user actions to local storage (SQLITE). All storage functions are located in **CurioDBToolkit.m** and **CurioDB.m**. When a user hooks up a function related to SDK, first of all CurioSDK stores it to local storage no matter we are online or not or have periodic dispatch requests (PDR) enabled or not.

For those requests CurioDBToolkit::addAction function runs to insert created action record to db. All actions converts to **CurioAction.m** object and stores and retrieves by serializating to CurioAction.

CurioAction object stored into SQLITE table named **ACTIONS** which is created on first run within **CurioDB.m**

Second workflow (which we will call submittance workflow) handles retrieval of records and transmittance to server side over internet. Main core functionality of this workflow runs on **CurioPostOffice.m** module. 

It starts to run in two way... one is periodically -if PDR is enabled- and other one is synchronized -if PDR is disabled-. Synchronized run has nothing to do with thread synchronization but running parallel with user actions. 


```
+--------+       +--------------+
|        |       |              |
| Curio  |       | User Actions |
| Server |       |              |
|        |       +------+-------+
+---^----+              |        
    |   SYNC          ASYNC      
    |                   |        
+---+----+              |        
|  Post  |         +----v----+   
| Office |         |DBToolkit|   
+---^----+         +----+----+   
    |                   |        
    |                   |        
  ASYNC               ASYNC      
    |       POOL        |        
    |    +---------+    |        
    |    |  Local  |    |        
    +----> Storage <----+        
         +---------+             
```

If PDR is enabled there is a sleeping thread runs in **CurioPostoffice::opQueue** queue and wakes up every dispatch period (which can be configured within settings) and runs **CurioPostoffice::tryToPostAwaitingActions** function to try to post actions stored in database. If PDR is not enabled, there is an internal notification name which is stored in **CS_NOTIF_NEW_ACTION** value globally which waits for any user action signal to run **CurioPostoffice::tryToPostAwaitingActions**. 

Most critical point in submittance workflow is localted within **CurioPostoffice::tryToPostAwaitingActions** function which handles mostly every conversions and transfers.

It requires to run in background thread if otherwise is not specified with **canRunOnMainThread** parameter. If it is not, it switches itself back to a background thread to not to intercept any user comfort. It checks whether device is online or not. If it is not, it switches awaiting records into offline records, otherwise tries to post actions ordered by action time which is saved in **aId** column.

It puts action objects into two arrays (if PDR is disabled just uses one array) to collect them in batch manner. First one is **offlineActions** and second one is **pdrActions** array. Main functionality within **CurioPostoffice::tryToPostAwaitingActions** is to iterate through records and collect them as PDR -if enabled- or Offline otherwise if they are online records then sending them to server immediately and in other cases pushing collected arrays to server as soon as they are finished.

Other than two main workflows, there is a **CurioNetwork.h** which handles network status changes and notifies with notification calls to all around the SDK. 






