//
//  FLAnimatedImageView+ImageURL.m
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

#import "FLAnimatedImageView+ImageURL.h"
#import "FLAnimatedImageView+WebCache.h"
#import "UIView+WebCache.h"


@implementation FLAnimatedImageView (ImageURL)

-(void)setImageUrl:(NSURL *)url{
    [self sd_setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self sd_setShowActivityIndicatorView:YES];
    [self sd_setImageWithURL:url placeholderImage:nil];
//  [self sd_setImageWithURL:url];
}

-(void)setImageUrl:(NSURL *)url completion:(void (^)(UIImage *))callback{
    [self sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
       callback(image);
    }];
}
-(void)setImageUrl:(NSURL *)url withHeight:(NSInteger)Height {
}


@end
