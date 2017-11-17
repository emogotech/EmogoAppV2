//
//  NSDictionary+NullRemover.h
//  LetsAllDoGood
//
//  Created by Pushpendra on 13/12/16.
//  Copyright © 2016 LetsAllDoGood Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullRemover)
- (NSDictionary *) dictionaryByReplacingNullsWithEmptyStrings;
@end
