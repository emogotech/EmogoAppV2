//
//  NSDictionary+NullRemover.h
//  LetsAllDoGood
//
//  Created by Vikas Goyal on 14/11/17.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullRemover)
- (NSDictionary *) dictionaryByReplacingNullsWithEmptyStrings;
@end
