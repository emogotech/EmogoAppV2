//
//  VGMetaDataFetcher.h
//  OGImageFromURL
//
//  Created by Vikas Goyal on 10/09/15.
//  Copyright (c) 2015 Krystallize. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATA_TYPE_OGIMAGE                      0
#define DATA_TYPE_OGTITLE                       1
#define DATA_TYPE_OGDESCRIPTION           2

@class VGMetaDataFetcher;

@protocol VGMetaDataFetcherDelegate <NSObject>
@optional

-(void) metaDataFetureWithRecievedOGImageURL:(NSString *)urlStr WithRecievedOGImage:(UIImage *)imge;
-(void) metaDataFeture:(VGMetaDataFetcher *)feture recievedOGTitleStr:(NSString *)title;
-(void) metaDataFeture:(VGMetaDataFetcher *)feture recievedOGDescriptionStr:(NSString *)Description;

//Failuer
-(void) metaDataFeture:(VGMetaDataFetcher *)feture requestFailedWithError:(NSError *)error;

@end

@interface VGMetaDataFetcher : NSObject{
    
}

@property (nonatomic,strong) id <VGMetaDataFetcherDelegate> delegate;

-(void)setupWebViewWithUrlStr:(NSString *) strURL;
-(void) vgCallForMetaWithUrlStr:(NSString*)urlStr forDataType:(int) dataType;
- (void)getOGImageFromSourceStr:(NSString *)sourceStr;

@end
