// The MIT License (MIT)
//
// Copyright (c) 2014 Todd Ditchendorf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TDTag.h"
#import "TDFragment.h"
#import <TDTemplateEngine/TDTemplateEngine.h>
#import <TDTemplateEngine/TDTemplateContext.h>
#import <TDTemplateEngine/TDWriter.h>
#import <TDTemplateEngine/XPExpression.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKWhitespaceState.h>

@interface TDNode ()
- (void)renderVerbatimInContext:(TDTemplateContext *)ctx;
@end

@interface TDTag ()
@property (nonatomic, retain) PKToken *endTagToken;
@end

@implementation TDTag

+ (NSString *)tagName {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
    return nil;
}


+ (TDTagType)tagType {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
    return 0;
}


- (instancetype)initWithToken:(PKToken *)frag {
    self = [super initWithToken:frag];
    if (self) {
        
    }
    return self;
}


- (void)dealloc {
    self.endTagToken = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark TDNode

- (void)renderInContext:(TDTemplateContext *)ctx {
    NSParameterAssert(ctx);
    if (self.suppressRendering) {
        self.suppressRendering = NO;
        return;
    }
    
    TDTemplateContext *local = [[[TDTemplateContext alloc] initWithVariables:nil output:ctx.writer.output] autorelease];
    local.enclosingScope = ctx;
    
    [self doTagInContext:local];
}


- (void)renderVerbatimInContext:(TDTemplateContext *)ctx {
    NSParameterAssert(ctx);
    if (self.suppressRendering) {
        self.suppressRendering = NO;
        return;
    }
    
    [super renderVerbatimInContext:ctx];
    
    TDWriter *writer = ctx.writer;
    TDFragment *frag = (id)self.endTagToken;
    NSString *str = frag.verbatimString;
    
    // text nodes don't store separate verbStr
    if (!str) {
        str = frag.stringValue;
    }
    [writer appendString:str];
}


#pragma mark -
#pragma mark TDTag

- (void)doTagInContext:(TDTemplateContext *)ctx {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
}


- (NSString *)tagName {
    return [[self class] tagName];
}

@end
