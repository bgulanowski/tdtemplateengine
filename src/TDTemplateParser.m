#import "TDTemplateParser.h"
#import <PEGKit/PEGKit.h>
    
#import <TDTemplateEngine/TDTemplateContext.h>
#import "TDRootNode.h"
#import "TDVariableNode.h"
#import "TDBlockStartNode.h"
#import "TDBlockEndNode.h"
#import "TDTextNode.h"


@interface TDTemplateParser ()
    
@property (nonatomic, retain) TDNode *currentParent;

@end

@implementation TDTemplateParser { }

- (id)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        
        self.startRuleName = @"template";
        self.tokenKindTab[@"block_start_tag"] = @(TDTEMPLATE_TOKEN_KIND_BLOCK_START_TAG);
        self.tokenKindTab[@"var"] = @(TDTEMPLATE_TOKEN_KIND_VAR);
        self.tokenKindTab[@"block_end_tag"] = @(TDTEMPLATE_TOKEN_KIND_BLOCK_END_TAG);
        self.tokenKindTab[@"empty_tag"] = @(TDTEMPLATE_TOKEN_KIND_EMPTY_TAG);
        self.tokenKindTab[@"text"] = @(TDTEMPLATE_TOKEN_KIND_TEXT);

        self.tokenKindNameTab[TDTEMPLATE_TOKEN_KIND_BLOCK_START_TAG] = @"block_start_tag";
        self.tokenKindNameTab[TDTEMPLATE_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[TDTEMPLATE_TOKEN_KIND_BLOCK_END_TAG] = @"block_end_tag";
        self.tokenKindNameTab[TDTEMPLATE_TOKEN_KIND_EMPTY_TAG] = @"empty_tag";
        self.tokenKindNameTab[TDTEMPLATE_TOKEN_KIND_TEXT] = @"text";

    }
    return self;
}

- (void)dealloc {
        
	self.staticContext = nil;
    self.currentParent = nil;


    [super dealloc];
}

- (void)start {

    [self template_]; 
    [self matchEOF:YES]; 

}

- (void)template_ {
    
    [self execute:^{
    
	TDAssert(_staticContext);
    TDNode *root = [TDRootNode rootNodeWithStaticContext:_staticContext];
	self.assembly.target = root;
    self.currentParent = root;

    }];
    do {
        [self content_]; 
    } while ([self predicts:TOKEN_KIND_BUILTIN_ANY]);

}

- (void)content_ {
    
    if ([self predicts:TDTEMPLATE_TOKEN_KIND_VAR, 0]) {
        [self var_]; 
    } else if ([self predicts:TDTEMPLATE_TOKEN_KIND_EMPTY_TAG, 0]) {
        [self empty_tag_]; 
    } else if ([self predicts:TDTEMPLATE_TOKEN_KIND_BLOCK_START_TAG, 0]) {
        [self block_]; 
    } else if ([self predicts:TDTEMPLATE_TOKEN_KIND_TEXT, 0]) {
        [self text_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'content'."];
    }

}

- (void)var_ {
    
    [self match:TDTEMPLATE_TOKEN_KIND_VAR discard:NO]; 
    [self execute:^{
    
	PKToken *tok = POP();
	TDNode *varNode = [TDVariableNode nodeWithToken:tok parent:_currentParent];
	[_currentParent addChild:varNode];

    }];

}

- (void)empty_tag_ {
    
    [self match:TDTEMPLATE_TOKEN_KIND_EMPTY_TAG discard:NO]; 
    [self execute:^{
    
	PKToken *tok = POP();
	TDNode *startTagNode = [TDBlockStartNode nodeWithToken:tok parent:_currentParent];
	[_currentParent addChild:startTagNode];
	self.currentParent = startTagNode;

    }];

}

- (void)block_ {
    
    [self execute:^{
     PUSH(_currentParent); 
    }];
    [self block_start_tag_]; 
    [self block_body_]; 
    [self block_end_tag_]; 
    [self execute:^{
     self.currentParent = POP(); 
    }];

}

- (void)block_start_tag_ {
    
    [self match:TDTEMPLATE_TOKEN_KIND_BLOCK_START_TAG discard:NO]; 
    [self execute:^{
    
	PKToken *tok = POP();
	TDNode *startTagNode = [TDBlockStartNode nodeWithToken:tok parent:_currentParent];
	[_currentParent addChild:startTagNode];
	self.currentParent = startTagNode;

    }];

}

- (void)block_end_tag_ {
    
    [self match:TDTEMPLATE_TOKEN_KIND_BLOCK_END_TAG discard:NO]; 
    [self execute:^{
    
    PKToken *tok = POP();
    ASSERT([_currentParent.name hasPrefix:[tok.stringValue substringFromIndex:3]]);

    }];

}

- (void)block_body_ {
    
    do {
        [self content_]; 
    } while ([self speculate:^{ [self content_]; }]);

}

- (void)text_ {
    
    [self match:TDTEMPLATE_TOKEN_KIND_TEXT discard:NO]; 
    [self execute:^{
    
	PKToken *tok = POP();
	TDNode *txtNode = [TDTextNode nodeWithToken:tok parent:_currentParent];
	[_currentParent addChild:txtNode];

    }];

}

@end
