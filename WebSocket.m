//
//  WebSocket.m
//  AIM Addict
//
//  Created by Ben Reeves on 12/05/2011.
//  Copyright 2011 Rainy Day Apps. All rights reserved.
//

#import "WebSocket.h"

const NSString * js = @"<html><body><script language=\"javascript\"type=\"text/javascript\">var websocket;var Base64={_keyStr:\"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=\",encode:function(input){var output=\"\";var chr1,chr2,chr3,enc1,enc2,enc3,enc4;var i=0;input=Base64._utf8_encode(input);while(i<input.length){chr1=input.charCodeAt(i++);chr2=input.charCodeAt(i++);chr3=input.charCodeAt(i++);enc1=chr1>>2;enc2=((chr1&3)<<4)|(chr2>>4);enc3=((chr2&15)<<2)|(chr3>>6);enc4=chr3&63;if(isNaN(chr2)){enc3=enc4=64;}else if(isNaN(chr3)){enc4=64;} output=output+ this._keyStr.charAt(enc1)+this._keyStr.charAt(enc2)+ this._keyStr.charAt(enc3)+this._keyStr.charAt(enc4);} return output;},_utf8_encode:function(string){string=string.replace(/\\r\\n/g,\"\\n\");var utftext=\"\";var n=0;for(n=0;n<string.length;n++){var c=string.charCodeAt(n);if(c<128){utftext+=String.fromCharCode(c);} else if((c>127)&&(c<2048)){utftext+=String.fromCharCode((c>>6)|192);utftext+=String.fromCharCode((c&63)|128);} else{utftext+=String.fromCharCode((c>>12)|224);utftext+=String.fromCharCode(((c>>6)&63)|128);utftext+=String.fromCharCode((c&63)|128);}} return utftext;}};function connect(url){if(websocket)websocket.close();websocket=new WebSocket(url);websocket.onopen=function(evt){window.location=\"onopen://\";};websocket.onclose=function(evt){window.location=\"onclose://\";};websocket.onmessage=function(evt){window.location=\"onreceive://\"+Base64.encode(evt.data);};websocket.onerror=function(evt){window.location=\"onerror://\"+Base64.encode(evt.data);};};</script></body></html>";

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@implementation WebSocket

@synthesize delegate;

+ (NSData *)decodeBase64StringToUTF8:(NSString *)strBase64 {
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	int intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
    
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
    
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
        
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
        
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
                
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
                
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
                
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
    
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
                
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
    
    return [[NSData alloc] initWithBytesNoCopy:objResult length:j freeWhenDone:YES];
}

-(void)connect:(NSString*)url_string {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"connect(\"%@\");", url_string]];

}

-(id)init {
    if ((self = [super init])) {
        
        webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                
        webView.delegate = self;
        
        [webView loadHTMLString:(NSString*)js baseURL:nil];
    }
    return self; 
}

-(void)dealloc {
    [webView stopLoading];
    webView.delegate = nil;
    
    [delegate release];
    [webView release];
    [super dealloc];
}

-(void)disconnect {
    [webView stringByEvaluatingJavaScriptFromString:@"websocket.close();"];
}

-(void)send:(NSString*)message {
    
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"websocket.send(\"%@\");", message]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL * url = [request URL];
    NSString * scheme = [url scheme];
            
    if ([scheme isEqualToString:@"onopen"]) {
        [delegate webSocketOnOpen:self];
        return NO;
    } else if ([scheme isEqualToString:@"onclose"]) {
        [delegate webSocketOnClose:self];
        return NO;
    } else if ([scheme isEqualToString:@"onerror"]) {
        NSString * string = [[url description] substringFromIndex:strlen("onreceive://")];

        [delegate webSocket:self onError:[NSError errorWithDomain:string code:1 userInfo:nil]];
        return NO;
    } else if ([scheme isEqualToString:@"onreceive"]) {        
        NSString * string = [[url description] substringFromIndex:strlen("onreceive://")];
                
        NSData * data = [WebSocket decodeBase64StringToUTF8:string];
    
        [delegate webSocket:self onReceive:data];
        return NO;
    }
        
    return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [delegate webSocketOnInitialized:self];;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [delegate webSocket:self onError:error];
}


@end
