//
//  UILabel+LineCounter.m
//  
//
//  Created by Pushpendra on 13/12/16.
//

#import "UILabel+LineCounter.h"

@implementation UILabel (LineCounter)

- (int)lineCountForLabel{
    CGSize constrain = CGSizeMake(self.bounds.size.width, FLT_MAX);
    CGRect labelRect = [self.text boundingRectWithSize:constrain options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
   return ceil(labelRect.size.height / self.font.lineHeight);
}
@end
