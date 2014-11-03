#Curio IOS SDK 1.0

[Curio](https://gui-curio.turkcell.com.tr) is Turkcell's mobile analytics system, and this is Curio's Android Client IOS library. Applications developed for IOS 6.0+ can easily use Curio mobile analytics with this library.

#Quick Startup Guide

You can drag'n drop Curio project file into your project. Additionally you should add the dependencies.

## Dependencies

You should Click on Targets -> Your App Name -> and then the 'Build Phases' tab.

![image](https://imagizer.imageshack.us/v2/1085x208q90/r/674/20ayY4.png)

And expand 'Link Binary With Library' and click + sign to add required framework if they are not available.

```
- Foundation.framework
- UIKit.framework
- CoreTelephony.framework
- libsqlite3.dylib 
```

If you don't want to run automated unit tests, then you should remove CurioSDKTests.m, CurioSettingsTest.m and CurioDBTests.m files from compilation by Click on Targets -> Your App Name -> And then the 'Build Phases' tab and expand Compile Sources to remove them by clicking on - sign while mentioned source files selected.

![image](https://imagizer.imageshack.us/v2/1085x446q90/r/746/bG8oCj.png)

#Configuration

There are two ways to configure CurioSDK.

### Automated Configuration

You can just copy'n paste CurioSDK item within sample project's Info.plist or CurioSDKTests-Info.plist contained in CurioSDK.Core tests to your project's Info.plist file and edit parameters as you wish.

![image](http://imagizer.imageshack.us/a/img674/4662/XtAgaE.jpg)

**ServerURL:** [Required] Curio server URL, can be obtained from Turkcell. 

**ApiKey:** [Required] Application specific API key, can be obtained from Turkcell.

**TrackingCode:** [Required] Application specific tracking code, can be obtained from Turkcell.

**SessionTimeout:** [Optional] Session timeout in minutes. Default is 30 minutes but it's highly recommended to change this value acording to the nature of your application. Specifiying a correct session timeout value for your application will increase the accuracy of the analytics data.

**PeriodicDispatchEnabled:** [Optional] Periodic dispatch is enabled if true. Default is false.

**DispatchPeriod:** [Optional] If periodic dispatch is enabled, this parameter configures dispatching period in minutes. Deafult is 5 minutes. **Note:** This parameter cannot be greater than session timeout value.

**MaxCachedActivityCount:** [Optional] Max. number of user activity that Curio library will remember when device is not connected to the Internet. Default is 1000. Max. value can be 4000.

**LoggingEnabled:** [Optional] All of the Curio logs will be disabled if this is false. Default is true.

**LogLevel:** [Optional] Contains level of the print-out logs.  0 - Error, 1 - Warning, 2 - Info, 3 - Debug. Default is 0 (Error).
 


### Manual Configuration

You can specify CurioSDK parameters whenever you want to start a session on client by invoking startSession function just like below.

```
[[CurioSDK shared] startSession:@"https://curiotest.turkcell.com.tr/api/v2"
					      apiKey:@"XXXXX"
					trackingCode:@"XXXXX"
				  sessionTimeout:4
		 periodicDispatchEnabled:TRUE
				dispatchPeriod:2
		maxCachedActivitiyCount:50
				 loggingEnabled:TRUE
				 logLevel:0];
```

## Usage

### Starting a session

You can start a session whenever application starts-up by invoking startSession function within CurioSDK class.

```
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[CurioSDK shared] startSession];
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




