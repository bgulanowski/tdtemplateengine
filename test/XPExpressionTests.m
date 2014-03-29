//
//  XPExpressionTests.m
//  TDTemplateEngineTests
//
//  Created by Todd Ditchendorf on 3/28/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"
#import "XPExpression.h"

@interface TDTemplateEngine ()
- (PKTokenizer *)tokenizer;
@end

@interface XPExpressionTests : XCTestCase
@property (nonatomic, retain) XPExpression *expr;
@property (nonatomic, retain) PKTokenizer *t;
@end

@implementation XPExpressionTests

- (void)setUp {
    [super setUp];
    
    self.expr = nil;
}

- (void)tearDown {
    self.expr = nil;
    
    [super tearDown];
}

- (NSArray *)tokenize:(NSString *)input {
    PKTokenizer *t = [[TDTemplateEngine templateEngine] tokenizer];
    t.string = input;
    t.whitespaceState.reportsWhitespaceTokens = NO;
    
    PKToken *tok = nil;
    PKToken *eof = [PKToken EOFToken];
    
    NSMutableArray *toks = [NSMutableArray array];
    
    while (eof != (tok = [t nextToken])) {
        [toks addObject:tok];
    }
    return toks;
}

- (void)test1 {
    NSString *input = @"1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test0 {
    NSString *input = @"0";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testYES {
    NSString *input = @"YES";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testNO {
    NSString *input = @"NO";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testTrue {
    NSString *input = @"true";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testFalse {
    NSString *input = @"false";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testOpenTrueClose {
    NSString *input = @"(true)";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testOpenFalseClose {
    NSString *input = @"(false)";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testSQString {
    NSString *input = @"'hello'";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)testEmptySQString {
    NSString *input = @"''";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Eq1 {
    NSString *input = @"1 eq 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1EqSign1 {
    NSString *input = @"1 = 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1EqEqSign1 {
    NSString *input = @"1 == 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Eq2 {
    NSString *input = @"1 eq 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1EqSign2 {
    NSString *input = @"1 = 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1EqEqSign2 {
    NSString *input = @"1 == 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Ne1 {
    NSString *input = @"1 ne 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1NeSign1 {
    NSString *input = @"1 != 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Ne2 {
    NSString *input = @"1 ne 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1NeSign2 {
    NSString *input = @"1 != 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Lt1 {
    NSString *input = @"1 < 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1LtEq1 {
    NSString *input = @"1 <= 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Lt2 {
    NSString *input = @"1 < 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1LtEq2 {
    NSString *input = @"1 <= 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Gt1 {
    NSString *input = @"1 > 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1GtEq1 {
    NSString *input = @"1 >= 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Gt2 {
    NSString *input = @"1 > 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1GtEq2 {
    NSString *input = @"1 >= 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1And0 {
    NSString *input = @"1 and 0";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test0And1 {
    NSString *input = @"0 and 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDFalse([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1And1 {
    NSString *input = @"1 and 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Or0 {
    NSString *input = @"1 or 0";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test0Or1 {
    NSString *input = @"0 or 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1Or1 {
    NSString *input = @"1 or 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDTrue([[expr simplify] evaluateAsBooleanInContext:nil]);
}

- (void)test1SpacePlusSpace2 {
    NSString *input = @"1 + 2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDEquals(3.0, [[expr simplify] evaluateAsNumberInContext:nil]);
}

- (void)test1Plus2 {
    NSString *input = @"1+2";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDEquals(3.0, [[expr simplify] evaluateAsNumberInContext:nil]);
}

- (void)test1SpaceMinusSpace1 {
    NSString *input = @"1 - 1";
    NSArray *toks = [self tokenize:input];
    
    NSError *err = nil;
    XPExpression *expr = [XPExpression expressionFromTokens:toks error:&err];
    TDNil(err);
    TDNotNil(expr);
    TDEquals(0.0, [[expr simplify] evaluateAsNumberInContext:nil]);
}

@end
