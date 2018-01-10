//
//  FLAnimatedImageView+ImageURL.m
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

#import "FLAnimatedImageView+ImageURL.h"
#import "FLAnimatedImageView+WebCache.h"

@implementation FLAnimatedImageView (ImageURL)

-(void)setImageUrl:(NSURL *)url{
    [self sd_setImageWithURL:url];
}
@end
