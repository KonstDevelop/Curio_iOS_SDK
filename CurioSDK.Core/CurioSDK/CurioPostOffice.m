//
//  CurioPostOffice.m
//  CurioSDK
//
//  Created by Harun Esur on 19/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CurioSDK.h"

#include <pthread.h>

@implementation CurioPostOffice

static NSOperationQueue *opQueue;
static pthread_mutex_t mutex;

+ (CS_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}



- (BOOL) checkResponse:(NSHTTPURLResponse *) response data:(NSData *) data  action:(CurioAction *) action{
    
    
    BOOL ret = FALSE;
    
    last_responseCode = (int)response.statusCode;
    
    CS_Log_Info(@"Status code: %ld %@",(long)[((NSHTTPURLResponse *)response) statusCode],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (response.statusCode == 200) {
        // Everything went well
        if (action != nil && action.actionType == CActionTypeStartScreen) {
            // Check for hit code
            NSString *screenClass = [action.properties objectForKey:CS_CUSTOM_VAR_SCREENCLASS];
            
            if (screenClass) {
             
                NSDictionary *ret =  [[CurioUtil shared] fromJson:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] percentEncoded:FALSE];
                
                NSString *hitCode = [NSString stringWithFormat:@"%@",[ret objectForKey:CS_HTTP_JSON_VARNAME_HITCODE]];
                
                CS_Log_Info(@"Retrieved hit code %@ for screen %@",hitCode,screenClass);
                
                [[CurioSDK shared].memoryStore setObject:hitCode
                                                  forKey:[NSString stringWithFormat:@"HC%@",screenClass]];
            }
            
            
        }
        
        return TRUE;
        
    } else if (response.statusCode == 401) {
        // UNAUTHORIZED
        
        CS_Log_Warning(@"Got UNAUTHORIZED code 401");
        
    } else if (response.statusCode == 412) {
        // Precondition failed
        // Wrong api-tracking etc.
        
        
    } else {
        // Another problem
        
        
    }
    
    return ret;
    
}

- (BOOL) postRequest:(CPostType) postType parameters:(NSDictionary *)parameters action:(CurioAction *) action {
    
    @synchronized(self) {
 
        NSString *suffix =     postType == CPostTypeOCR ? CS_SERVER_URL_SUFFIX_OFFLINE_CACHE :
        postType == CPostTypePDR ? CS_SERVER_URL_SUFFIX_PERIODIC_BATCH :
        postType == CPostTypeStartScreen ? CS_SERVER_URL_SUFFIX_SCREEN_START :
        postType == CPostTypeStartSession ? CS_SERVER_URL_SUFFIX_SESSION_START :
        postType == CPostTypeSendEvent ? CS_SERVER_URL_SUFFIX_SEND_EVENT :
        postType == CPostTypeEndSession ? CS_SERVER_URL_SUFFIX_SESSION_END :
        postType == CPostTypeEndScreen ? CS_SERVER_URL_SUFFIX_SCREEN_END : @"";

        NSString *sUrl = [NSString stringWithFormat:@"%@/%@",[[CurioSettings shared] serverUrl],suffix];
    
        CS_Log_Info(@"URL: %@ %@",sUrl,CS_RM_STR_NEWLINE(parameters));

        NSURL *url = [NSURL URLWithString:sUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:NO];
        [request setValue:CS_OPT_USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [request setHTTPBody:[[[CurioUtil shared] dictToPostBody:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setTimeoutInterval:30.0];
    
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data  = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        BOOL responseOk = [self checkResponse:(NSHTTPURLResponse *)response data:data action:action];
        
        if (error != nil) {
            CS_Log_Warning(@"Warning: %ld , %@",(long)error.code, error.localizedDescription);
            
            last_errorCode = (long) error.code;
        } else {
            last_errorCode = 0;
        }
        
        return error == nil && responseOk;
        
    }
    
    
}


- (BOOL) postAction:(CurioAction *)action {
    
    
    CPostType type = action.actionType == CActionTypeStartSession ? CPostTypeStartSession :
    action.actionType == CActionTypeStartScreen ? CPostTypeStartScreen :
    action.actionType == CActionTypeEndScreen ? CPostTypeEndScreen :
    action.actionType == CActionTypeEndSession ? CPostTypeEndSession :
    action.actionType == CActionTypeSendEvent ? CPostTypeSendEvent : 0;
    
    return [self postRequest:type parameters:[[CurioActionToolkit shared] actionToOnlinePostParameters:action] action:action];
}


- (BOOL) postPeriodicDispatchActions:(NSArray *)actions {
    
    
    return [self postRequest:CPostTypePDR parameters:[[CurioActionToolkit shared] actionsToPDRPostParameters:actions] action:nil];
}

- (BOOL) postOfflineActions:(NSArray *)actions {
    
    
    return [self postRequest:CPostTypeOCR parameters:[[CurioActionToolkit shared] actionsToOCRPostParameters:actions] action:nil];
}

- (BOOL) tryToFixResponseProblems:(CurioPostOfficeRetryBlock) retryBlock {
    
    // Precondition failed
    if (last_responseCode == 412) {
        
        CS_Log_Error(@"Invalid Api Key and/or Tracking Code !!!");
        return FALSE;
    }
    
    // Timeout mode
    if (last_errorCode == -1001) {
        CS_Log_Error(@"On timeouts, there is no need to retry !!!");
        return FALSE;
    }
    
    BOOL fixed =false;
    for (int i=0;i<CS_OPT_MAX_POST_OFFICE_RETRY_COUNT;i++) {

        
        CS_Log_Info(@"Re-trying to fix problem.. attempt no: %d last response code: %d",i+1,last_responseCode);
        // It is UNAUTHORIZED.
        // Probably lost session on server side
        // Try to re-enable session
        if (last_responseCode == 401 || last_responseCode == 0) {
            
            [[CurioSDK shared] reGenerateSessionCode];
            
            CurioAction *startSession = [CurioAction actionStartSession];
            
            if ([self postAction:startSession]) {
                if (retryBlock()) {
                    
                    CS_Log_Info(@"Problem fixed by creating new session");
                    fixed = true;
                    break;
                    
                }
            } else {
                
                CS_Log_Error(@"Could not fix response problem. Last status code: %d",last_responseCode);
                
            }
        } else {
            if (retryBlock()) {
                CS_Log_Info(@"Retry worked... problem fixed.");
                fixed = true;
            }
        }
        
    }
    
    if (!fixed) {
        CS_Log_Warning(@"No luck at fixing problem. Status code: %d",last_responseCode);
    }
    
    return fixed;
    
}

- (void) flushAwaitingOfflineActions:(NSMutableArray *)oactions {
    
    if (oactions.count  > 0 )
    {
        if ([self postOfflineActions:oactions]) {
            [[CurioDBToolkit shared] deleteRecords:oactions];
            [oactions removeAllObjects];
        } else {
            // A Problem with offline post
            [self tryToFixResponseProblems:^BOOL{
                if ([self postOfflineActions:oactions]) {
                    [[CurioDBToolkit shared] deleteRecords:oactions];
                    [oactions removeAllObjects];
                    return TRUE;
                }
                
                return FALSE;
            }];
        }
    }

}

- (void) flushAwaitingPDRActions:(NSMutableArray *)pactions {
    
    
    if (pactions.count > 0) {
        if ([self postPeriodicDispatchActions:pactions]) {
            [[CurioDBToolkit shared] deleteRecords:pactions];
            [pactions removeAllObjects];
        } else {
            // A Problem with pdr post
            [self tryToFixResponseProblems:^BOOL{
                if ([self postPeriodicDispatchActions:pactions]) {
                    [[CurioDBToolkit shared] deleteRecords:pactions];
                    [pactions removeAllObjects];
                    
                    return TRUE;
                }
                return FALSE;
            }];
        }
    }

}

- (void) tryToPostAwaitingActions:(BOOL) canRunOnMainThread {
    

    
    if (pthread_mutex_trylock(&mutex) != 0)
    {
        return;
    }
    
    
    // To make sure we are not running
    // in main thread
    if ([NSThread isMainThread] && canRunOnMainThread) {
        
        pthread_mutex_unlock(&mutex);

        [opQueue addOperationWithBlock:^{
            [self tryToPostAwaitingActions:canRunOnMainThread];
        }];
        
        
        return;
    }
    
    NSArray *actions = [[CurioDBToolkit shared] getActions:CS_OPT_MAX_ACTION_TO_READ_PER_POST];
    
    // We are not online so we should mark records we fetched
    // as offline records because it should be sent as offline
    // cache records next time
    if (![[CurioNetwork shared] isOnline]) {
        
        [[CurioDBToolkit shared] markAsOfflineRecords:actions];
    } else {
    // We are online... it is good to go
        
        
        NSMutableArray *offlineActions = [NSMutableArray new];
        NSMutableArray *pdrActions = [NSMutableArray new];
        
        int _curActioNum = 0;
        
        for (CurioAction *action in actions) {
            
            _curActioNum++;
            
            CS_Log_Debug(@"Processing actions %d of %lu - %@ %@",_curActioNum,(unsigned long)[actions count],action.isOnline,[NSNumber numberWithBool:TRUE]);
            
            if (CS_NSN_IS_TRUE(action.isOnline)) {
                
                [self flushAwaitingOfflineActions:offlineActions];
                
                if (CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])
                    && action.actionType != CActionTypeStartSession
                    && action.actionType != CActionTypeEndSession) {
                    
                    [pdrActions addObject:action];
                    
                } else  {
                    
                    // ONLINE POST IN ONLINE STATE
                    if ([self postAction:action]) {
                        [[CurioDBToolkit shared] deleteRecords:[NSArray arrayWithObject:action]];
                    } else  {
                        

                        // A Problem with online post
                        BOOL fixed = (action.actionType == CActionTypeEndSession) ? FALSE :
                        [self tryToFixResponseProblems:^BOOL{
                            if ([self postAction:action]) {
                                [[CurioDBToolkit shared] deleteRecords:[NSArray arrayWithObject:action]];
                                
                                return TRUE;
                            }
                            
                            return FALSE;
                        }];
                        
                        if (!fixed) {
                            [[CurioDBToolkit shared] markAsOfflineRecords:[NSArray arrayWithObject:action]];
                        }
                    }
                }
                
              
                
            } else {
                

                
                [self flushAwaitingPDRActions:pdrActions];
                
                [offlineActions addObject:action];
            }
            
        }
        
        [self flushAwaitingOfflineActions:offlineActions];
        [self flushAwaitingPDRActions:pdrActions];
        
        
        
    }
    
     pthread_mutex_unlock(&mutex);
    
    
    // If we read as max as we could that means
    // there may be more records to work on
    // So in case that there is, we are running same function again
    if (actions.count == CS_OPT_MAX_ACTION_TO_READ_PER_POST) {
        CS_Log_Debug(@"Trying to post rest of the actions...");
        [self tryToPostAwaitingActions:canRunOnMainThread];
    }
    
   
    
}

- (void) newActionNotified_background:(id) sender {
    
    if (!CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
        
        
        [self tryToPostAwaitingActions:FALSE];
        
    }
}

- (void) newActionNotified:(id) sender {
    

    [self performSelectorInBackground:@selector(newActionNotified_background:) withObject:sender];
    
}

- (id) init {
    if ((self = [super init])) {
        
        
        if (opQueue == nil) {
            
            pthread_mutex_init(&mutex, NULL);

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newActionNotified:) name:CS_NOTIF_NEW_ACTION object:nil];
            
            opQueue = [NSOperationQueue new];
            [opQueue setMaxConcurrentOperationCount:2];
            
            [opQueue addOperationWithBlock:^{
               
                while (1) {
                    
                    if (CS_NSN_IS_TRUE([[CurioSettings shared] periodicDispatchEnabled])) {
                        
                        [NSThread sleepForTimeInterval:[[[CurioSettings shared] dispatchPeriod] intValue] * 60];
                        
                        [self tryToPostAwaitingActions:FALSE];
                    } else {
                        
                        [NSThread sleepForTimeInterval:60];
                    }
                }
            }];
        }
    }
    return self;
}



@end
