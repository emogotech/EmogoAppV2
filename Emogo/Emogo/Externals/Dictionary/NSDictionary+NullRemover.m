//
//  NSDictionary+NullRemover.m
//  LetsAllDoGood
//
//  Created by Pushpendra on 13/12/16.
//  Copyright © 2016 LetsAllDoGood Inc. All rights reserved.
//

#import "NSDictionary+NullRemover.h"

@implementation NSDictionary (NullRemover)
- (NSDictionary *) dictionaryByReplacingNullsWithEmptyStrings {
    
    const NSMutableDictionary *replaced = [NSMutableDictionary new];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    for(NSString *key in self) {
        const id object = [self objectForKey:key];
        if(object == nul) {
            [replaced setObject:blank forKey:key];
            if ([object isKindOfClass:[NSString class]]) {
                if ([[object lowercaseString] isEqualToString:@"null"]) {
                    [replaced setObject:blank forKey:key];
                }
            }
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [replaced setObject:[object dictionaryByReplacingNullsWithEmptyStrings] forKey:key];
        } else if ([object isKindOfClass:[NSArray class]]) {
          [replaced setObject:[self arrayByReplacingNullsWithEmptyStrings:object] forKey:key];
        } else {
            [replaced setObject:object forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:(NSDictionary*)replaced];
}

- (NSArray *) arrayByReplacingNullsWithEmptyStrings:(NSArray *)array {
    const NSMutableArray *replaced = [NSMutableArray new];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    for (int i=0; i<[array count]; i++) {
        const id object = [array objectAtIndex:i];
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            [replaced setObject:[object dictionaryByReplacingNullsWithEmptyStrings] atIndexedSubscript:i];
        } else if ([object isKindOfClass:[NSArray class]]) {
         //   [replaced setObject:[object arrayByReplacingNullsWithEmptyStrings] atIndexedSubscript:i];
        } else if (object == nul){
            [replaced setObject:blank atIndexedSubscript:i];
        } else {
            [replaced setObject:object atIndexedSubscript:i];
        }
    }
    return [NSArray arrayWithArray:(NSArray*)replaced];
}

@end
