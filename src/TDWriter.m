//
//  TDWriter.m
//  TDTemplateEngine
//
//  Created by Todd Ditchendorf on 4/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TDWriter.h"

@implementation TDWriter

+ (instancetype)writerWithOutputStream:(NSOutputStream *)output {
    return [[[self alloc] initWithOutputStream:output] autorelease];
}


- (instancetype)initWithOutputStream:(NSOutputStream *)output {
    self = [super init];
    if (self) {
        self.output = output;
    }
    return self;
}


- (void)dealloc {
    self.output = nil;
    [super dealloc];
}


- (void)appendString:(NSString *)str {
    TDAssert(_output);
    TDAssert(str);
    
    NSUInteger len = [str length];
    if (len) {
        const uint8_t *zstr = (const uint8_t *)[str UTF8String];
        NSInteger c = len;
        do {
            NSInteger res = [_output write:zstr maxLength:len];
            if (-1 == res) {
                [NSException raise:@"TODO" format:@"TODO"];
            }
            c -= res;
        } while (c > 0);
    }
}


- (void)appendFormat:(NSString *)fmt, ... {
    va_list vargs;
    va_start(vargs, fmt);
    
    NSString *str = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];
    [self appendString:str];
    
    va_end(vargs);
}

@end