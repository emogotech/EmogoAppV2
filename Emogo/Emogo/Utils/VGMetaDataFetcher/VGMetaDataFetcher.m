//
//  VGMetaDataFetcher.m
//  OGImageFromURL
//
//  Created by Vikas Goyal on 10/09/15.
//  Copyright (c) 2015 Krystallize. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VGMetaDataFetcher.h"
#import "NSString+HTML.h"

@interface VGMetaDataFetcher ()<UIWebViewDelegate>{
    NSString* domainStr;
    UIWebView *tempWebView;
}

@end

@implementation VGMetaDataFetcher

- (NSURL *)smartURLForString:(NSString *)str{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    str = (str == nil ? @"sample" : str);
    assert(str != nil);
    result = nil;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSRange range = [str rangeOfString:@".html"];
//    if ((range.location +5) == str.length) {
//        str = [str stringByReplacingOccurrencesOfString:@".html" withString:@""];
//    }

    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    trimmedStr = [NSString stringWithFormat:@"%@",tempStr];
//    trimmedStr = [[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            trimmedStr = ([trimmedStr containsString:@"www"] ? trimmedStr : [NSString stringWithFormat:@"www.%@", trimmedStr]);
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
                [NSException raise:@"unsupported URL scheme" format:@"check entered url"];
            }
        }
    }
    return result;
}

-(void) vgCallForMetaWithUrlStr:(NSString *)urlStr forDataType:(int) dataType{
    NSString* userAgent = @"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8) Gecko/20100101 Firefox/1.5 BAVM/1.0.0";
    NSURL* url = [self smartURLForString:urlStr];
    domainStr = [url host];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [self.delegate performSelector:@selector(metaDataFeture:requestFailedWithError:) withObject:self withObject:connectionError];
        }
        else{
            switch (dataType) {
                case DATA_TYPE_OGIMAGE:
                    [self getOGImageFromSourceData:data];
                    break;
                    
                case DATA_TYPE_OGTITLE:
                    [self getOGTitleFromSourceData:data];
                    break;
                    
                case DATA_TYPE_OGDESCRIPTION:
                    [self getOGDescriptionFromSourceData:data];
                    break;
            }
        }
    }];
}

- (void) getOGTitleFromSourceData:(NSData *)sourceData{
}

- (void)getOGDescriptionFromSourceData:(NSData *)sourceData{
    NSError* error = nil;
    NSString *data_str = [[NSString alloc] initWithData:sourceData encoding:NSASCIIStringEncoding];
    
    // prepare regular expression to find text
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern: @"<meta name=\"description\".*?content=\"(.*?)\".*?>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regexp firstMatchInString:data_str options:0 range:NSMakeRange(0, data_str.length)];
    NSRange resultRange = [match rangeAtIndex:0];
    NSLog(@"match=%@", [data_str substringWithRange:resultRange]);
    
    //====Other Reguler Exp==
    NSRegularExpression *regexp0 = [NSRegularExpression regularExpressionWithPattern: @"<meta content=\"(.*?)\" property=\"og:description\">" options:NSRegularExpressionCaseInsensitive error:&error];
    
    // find by regular expression
    NSTextCheckingResult *match0 = [regexp0 firstMatchInString:data_str options:0 range:NSMakeRange(0, data_str.length)];
    
    // get the first result
    NSRange resultRange0 = [match0 rangeAtIndex:0];
    //================
    
    if (match) {
        NSString * rangeStr = [data_str substringWithRange:resultRange];
        if (rangeStr.length <= 36) {
            [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:@""];
            return;
        }
        
        NSString * descStr = @"";
        if (resultRange.length > 39) {
            NSRange descRange = NSMakeRange(resultRange.location + 34, resultRange.length - 38);
            descStr = [NSString stringWithFormat:@"%@",[data_str substringWithRange:descRange]];
            // get the og:image URL from the find result
            descStr = [descStr stringByReplacingOccurrencesOfString:@"\"og:description\" content=\"" withString:@""];
            descStr = [descStr stringByReplacingOccurrencesOfString:@"\"description\" content=\"" withString:@""];
            NSLog(@"descStr=%@", descStr);
        }
        [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:descStr];
    }
    else if (match0){
        NSString * descStr = [data_str substringWithRange:resultRange0];
        if (descStr != nil && descStr.length > 0) {
            @try {
                descStr = [descStr stringByDecodingHTMLEntities];
            }
            @catch (NSException *exception) {
                NSLog(@"exception=%@", exception.description);
            }
        }
        descStr = [self getTrimmedURLStringFor:descStr forDataType:DATA_TYPE_OGDESCRIPTION];

        NSLog(@"descStr=%@", descStr);
        [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:descStr];
    }
    else{
        
        NSString * ogMatch0Desc = @"";
        if ([data_str containsString:@"<meta property=\"og:description\" content=\""]) {
            NSRange firstRange = [data_str rangeOfString:@"<meta property=\"og:description\" content=\""];
            int finalStartLoc = (int)(firstRange.location + firstRange.length);
            NSString *secondStr = [data_str substringFromIndex:finalStartLoc];
            NSRange secondRange = [secondStr rangeOfString:@"/>"];
            int finalEndLoc = (int)(secondRange.location);
            NSRange finalRange = NSMakeRange(finalStartLoc, finalEndLoc);
            ogMatch0Desc = [data_str substringWithRange:finalRange];
            ogMatch0Desc = [ogMatch0Desc stringByReplacingOccurrencesOfString:@" " withString:@""];
            ogMatch0Desc = [ogMatch0Desc stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }

        // prepare regular expression to find text
        NSRegularExpression *regexp1 = [NSRegularExpression regularExpressionWithPattern: @"<meta property=\"og:description\" content=\"(.*?)\".*?>" options:NSRegularExpressionCaseInsensitive error:&error];
        
        // find by regular expression
        NSTextCheckingResult *match1 = [regexp1 firstMatchInString:data_str options:0 range:NSMakeRange(0, data_str.length)];
        
        // get the first result
        NSRange resultRange1 = [match1 rangeAtIndex:0];
        NSLog(@"match=%@", [data_str substringWithRange:resultRange1]);
        
        if (match1 || ogMatch0Desc.length > 0) {
            if (match1) {
                NSString * rangeStr = [data_str substringWithRange:resultRange1];
                if (rangeStr.length <= 44) {
                    [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:@""];
                    return;
                }
                
                
                // get the og:image URL from the find result
                NSRange descRange1 = NSMakeRange(resultRange1.location + 41, resultRange1.length - 40 - 3);
                
                NSString * descStr1 = [data_str substringWithRange:descRange1];
                @try {
                    descStr1 = [descStr1 stringByDecodingHTMLEntities];
                }
                @catch (NSException *exception) {
                    NSLog(@"exception=%@", exception.description);
                }
                NSLog(@"descStr=%@", descStr1);
                [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:descStr1];
            }
            else{
                [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:ogMatch0Desc];
            }
        }
        else{
            [self.delegate performSelector:@selector(metaDataFeture:recievedOGDescriptionStr:) withObject:self withObject:@""];
        }
    }
}

- (void)getOGImageFromSourceData:(NSData *)sourceData{
    NSError* error = nil;
    NSString *data_str = [[NSString alloc] initWithData:sourceData encoding:NSASCIIStringEncoding];
    
    if ([data_str containsString:@"og:image"]) {
        // prepare regular expression to find text
        NSString * ogMatch0URL = @"";
        if ([data_str containsString:@"<meta property=\"og:image\" content=\""]) {
            @try {
                NSRange firstRange = [data_str rangeOfString:@"<meta property=\"og:image\" content=\""];
                int finalStartLoc = (int)(firstRange.location + firstRange.length);
                NSString *secondStr = [data_str substringFromIndex:finalStartLoc];
                NSRange secondRange = [secondStr rangeOfString:@"/>"];
                int finalEndLoc = (int)(secondRange.location);
                if(finalEndLoc > 0){
                    NSRange finalRange = NSMakeRange(finalStartLoc, finalEndLoc);
                    ogMatch0URL = [data_str substringWithRange:finalRange];
                    ogMatch0URL = [ogMatch0URL stringByReplacingOccurrencesOfString:@" " withString:@""];
                    ogMatch0URL = [ogMatch0URL stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"exception = %@", exception.description);
            }
        }
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern: @"<meta property=\"og:image\" content=\"(.*?)\">" options:0 error:&error];
        NSTextCheckingResult *match = [regexp firstMatchInString:data_str options:0 range:NSMakeRange(0, data_str.length)];
        NSRange resultRange = [match rangeAtIndex:0];
        NSLog(@"match=%@", [data_str substringWithRange:resultRange]);
        
        //====Other Reguler Exp==
        NSRegularExpression *regexp1 = [NSRegularExpression regularExpressionWithPattern: @"<meta content=\"(.*?)\" property=\"og:image\">" options:0 error:&error];
        
        // find by regular expression
        NSTextCheckingResult *match1 = [regexp1 firstMatchInString:data_str options:0 range:NSMakeRange(0, data_str.length)];
        
        // get the first result
        NSRange resultRange1 = [match1 rangeAtIndex:0];

        //================
        if (match || ogMatch0URL.length > 0) {
            if (match) {
                // get the og:image URL from the find result
                NSRange urlRange = NSMakeRange(resultRange.location + 35, resultRange.length - 35 - 1);
                // og:image URL
                NSString * urlStr = [data_str substringWithRange:urlRange];
                if ([urlStr containsString:@"/>"]) {
                    NSRange range = [urlStr rangeOfString:@"/>"];
                    urlStr = [urlStr substringToIndex:range.location];
                }
                [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:urlStr withObject:nil];
            }
            else{
                [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:ogMatch0URL withObject:nil];
            }
        }
        
        else if (match1){
            NSString * urlStr = [data_str substringWithRange:resultRange1];
            urlStr = [self getTrimmedURLStringFor:urlStr forDataType:DATA_TYPE_OGIMAGE];
            [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:urlStr withObject:nil];
        }
        else{
            [self downloadImagesFor:[self getImgsInHTLMString:data_str]];
        }
    }
    else{
        [self downloadImagesFor:[self getImgsInHTLMString:data_str]];
    }
}

-(NSMutableArray *) getImgsInHTLMString:(NSString *) htmlStr{
    NSMutableArray * imgArrs = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    [regex enumerateMatchesInString:htmlStr options:0 range:NSMakeRange(0, [htmlStr length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             if ([imgArrs count] < 10) {
                                 NSDictionary * dict = @{
                                                         @"urlStr" : [htmlStr substringWithRange:[result rangeAtIndex:2]]
                                                         };
                                 [imgArrs addObject:dict];
                             }
                         }];
    
    return imgArrs;
}

-(void)downloadImagesFor:(NSMutableArray *) arrCollectio{
    if (arrCollectio.count > 0) {
        for (int i = 0; i < arrCollectio.count; i++) {
            NSDictionary * dict = [arrCollectio objectAtIndex:i];
            NSString * url = [dict objectForKey:@"urlStr"];
            NSString *firstLetter = (url.length > 5 ? [url substringToIndex:1] : @"");
            if ([firstLetter isEqualToString:@"/"]) {
                url = [NSString stringWithFormat:@"%@%@", domainStr, url];
            }
            NSURLResponse* response = nil;
            NSError* error = nil;
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
            NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            UIImage *image = [UIImage imageWithData:data];
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            if (image != nil && ((width >= 200 && height >= 150) || (height >= 200 && width >= 150))) {
                [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:url withObject:image];
                break;
            }
            if (i == arrCollectio.count - 1) {
                [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:@"" withObject:nil];
            }
        }
    }
    else{
        [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:@"" withObject:nil];
    }
}

#pragma mark For Extensions
- (void)getOGImageFromSourceStr:(NSString *)sourceStr{
    NSError* error = nil;
    if ([sourceStr containsString:@"og:image"]) {
        // prepare regular expression to find text
        NSString * ogMatch0URL = @"";
        if ([sourceStr containsString:@"<meta property=\"og:image\" content=\""]) {
            NSRange firstRange = [sourceStr rangeOfString:@"<meta property=\"og:image\" content=\""];
            int finalStartLoc = (int)(firstRange.location + firstRange.length);
            NSString *secondStr = [sourceStr substringFromIndex:finalStartLoc];
            NSRange secondRange = [secondStr rangeOfString:@"/>"];
            int finalEndLoc = (int)(secondRange.location);
            NSRange finalRange = NSMakeRange(finalStartLoc, finalEndLoc);
            ogMatch0URL = [sourceStr substringWithRange:finalRange];
            ogMatch0URL = [ogMatch0URL stringByReplacingOccurrencesOfString:@" " withString:@""];
            ogMatch0URL = [ogMatch0URL stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }

        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern: @"<meta property=\"og:image\" content=\"(.*?)\">" options:0 error:&error];
        NSTextCheckingResult *match = [regexp firstMatchInString:sourceStr options:0 range:NSMakeRange(0, sourceStr.length)];
        NSRange resultRange = [match rangeAtIndex:0];
        NSLog(@"match=%@", [sourceStr substringWithRange:resultRange]);
        
        //====Other Reguler Exp==
        NSRegularExpression *regexp1 = [NSRegularExpression regularExpressionWithPattern: @"<meta content=\"(.*?)\" property=\"og:image\">" options:0 error:&error];
        
        // find by regular expression
        NSTextCheckingResult *match1 = [regexp1 firstMatchInString:sourceStr options:0 range:NSMakeRange(0, sourceStr.length)];
        
        // get the first result
        NSRange resultRange1 = [match1 rangeAtIndex:0];
        NSLog(@"match1=%@", [sourceStr substringWithRange:resultRange1]);
        //================
        if (match) {
            // get the og:image URL from the find result
            NSRange urlRange = NSMakeRange(resultRange.location + 35, resultRange.length - 35 - 1);
            // og:image URL
            NSString * urlStr = [sourceStr substringWithRange:urlRange];
            if ([urlStr containsString:@"/>"]) {
                NSRange range = [urlStr rangeOfString:@"/>"];
                urlStr = [urlStr substringToIndex:range.location];
            }
            [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:urlStr withObject:nil];
        }
        
        else if (match1){
            // get the og:image URL from the find result
            NSRange urlRange1 = NSMakeRange(resultRange1.location + 15, resultRange1.length - 37);
            
            // og:image URL
            NSString * urlStr = [sourceStr substringWithRange:urlRange1];
            if ([urlStr containsString:@"/>"]) {
                NSRange range = [urlStr rangeOfString:@"/>"];
                urlStr = [urlStr substringToIndex:range.location];
            }
            [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:urlStr withObject:nil];
        }
        else{
            
            [self downloadImagesFor:[self getImgsInHTLMString:sourceStr]];
        }
    }
    else{
        [self downloadImagesFor:[self getImgsInHTLMString:sourceStr]];
    }
}


#pragma mark - WebView
-(void)setupWebViewWithUrlStr:(NSString *) strURL{
    tempWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 150.0)];
    tempWebView.delegate=self;
    tempWebView.scalesPageToFit=YES;
    tempWebView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[self smartURLForString:strURL]];
    [tempWebView loadRequest:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self performSelector:@selector(getImageForWebView) withObject:nil afterDelay:10.0];
//    [self getImageForWebView];
}

-(void) getImageForWebView{
    UIImage *image=[self captureScreen:tempWebView];
    if(image!=nil){
        [self.delegate performSelector:@selector(metaDataFetureWithRecievedOGImageURL:WithRecievedOGImage:) withObject:nil withObject:image];
    }
    tempWebView = nil;
}

-(UIImage*)captureScreen:(UIView*) viewToCapture{
    UIGraphicsBeginImageContext(viewToCapture.bounds.size);
    [viewToCapture.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

-(NSString *)getTrimmedURLStringFor:(NSString *)untrimmedStr forDataType:(int) dataType{
    NSString * strMetaData;
    switch (dataType) {
        case DATA_TYPE_OGIMAGE:
            strMetaData = @"og:image";
            break;
            
        case DATA_TYPE_OGTITLE:
            strMetaData = @"og:title";
            break;
            
        case DATA_TYPE_OGDESCRIPTION:
            strMetaData = @"og:description";
            break;
    }

    NSRange rangeEnd = [untrimmedStr rangeOfString:[NSString stringWithFormat:@"property=\"%@\">", strMetaData] options:NSBackwardsSearch];
    NSRange rangeStart = [untrimmedStr rangeOfString:@"<meta content=" options:NSBackwardsSearch];
    NSRange createRange = NSMakeRange(rangeStart.location + rangeStart.length, rangeEnd.location - rangeStart.location - rangeStart.length);
    NSString *trimmedStr = [untrimmedStr substringWithRange:createRange];
    trimmedStr=[trimmedStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return trimmedStr;
}
@end
