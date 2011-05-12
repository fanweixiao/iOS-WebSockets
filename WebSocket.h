//
//  WebSocket.h
//  AIM Addict
//
//  Created by Ben Reeves on 12/05/2011.
//  Copyright 2011 Rainy Day Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebSocket;

@protocol WebSocketDelegate
@required
-(void)webSocketOnOpen:(WebSocket*)webSocket;
-(void)webSocketOnClose:(WebSocket*)webSocket;
-(void)webSocket:(WebSocket*)webSocket onError:(NSError*)error;
-(void)webSocket:(WebSocket*)webSocket onReceive:(NSString*)message;
@end

@interface WebSocket : NSObject <UIWebViewDelegate> {
    UIWebView * webView;
    NSObject<WebSocketDelegate> * delegate;
}

@property(nonatomic, retain) NSObject<WebSocketDelegate> * delegate;

-(id)initWithURLString:(NSString*)urlString;

-(void)send:(NSString*)message;

@end
