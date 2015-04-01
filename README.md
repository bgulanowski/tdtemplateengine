TDTemplateEngine
================

###A multi-pass, streaming template engine implemented in Cocoa, for use in Cocoa. 

TDTemplateEngine is a template engine implemented in Objective-C, and intended for use on Apple's OS X and iOS platforms. It currently has decent unit test coverage.

**Always use the Xcode Workspace `TDTemplateEngine.xcworkspace`, *NOT* the Xcode Project.**

TDTemplateEngine is built on top of [PEGKit](https://github.com/itod/pegkit#pegkit), my parsing toolkit for Cocoa. The PEGKit dependency is managed via [git externals](http://nopugs.com/ext-tutorial).

TDTemplateEngine is inspired by the [Django template language](https://docs.djangoproject.com/en/dev/topics/templates/), [Java ServerPages](http://en.wikipedia.org/wiki/JavaServer_Pages "JavaServer Pages - Wikipedia, the free encyclopedia"), and [MGTemplateEngine](http://mattgemmell.com/mgtemplateengine-templates-with-cocoa "MGTemplateEngine - Templates with Cocoa - Matt Gemmell") by Matt Gemmell.

####Similarity to MGTemplateEngine
In fact, TDTemplateEngine's API is very much inspired by [MGTemplateEngine](https://github.com/mattgemmell/MGTemplateEngine). And usage scenarios of the two tools are very similar. If you are in need of a template engine for Cocoa, you should definitely investigate MGTemplateEngine as well. It is more mature.

So if MGTemplateEngine exists, why create another one? What makes TDTemplateEngine different?

###Design Goals of TDTemplateEngine

####Mutliple-pass
TDTemplateEngine offers a **multiple-pass architecture**. This means that TDTemplateEngine's API allows renderinging of any given template in *2 distinct phases*: 

1. **Compile** the template source to an intermediate [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST) representation.
1. **Render** the AST to the final template text result.
    
This multiple-pass architecture has many advantages:

* A clean, well-factored, classic archecture that should be recognizable for anyone familiar with compiler design basics. It should be easy to jump into the code and add or remove features without breaking things.
* Any use case where a template must be loaded into memory and compiled once, but rendered with runtime data multiple times should see a performance benefit.
* TDTemplateEngine's expression language should exhibit good performance in such *compile-once, render-often* scenarios: tempate expressions are compiled once, and some compile-time optimizations are performed before render-time. Currently, the expression language optimizations are quite rudimentary, but the hooks are there, and they could be further improved with well-known compiler techniques.
* With a powerful parser, multiple parser passes, and an intermediate AST representation, TDTemplateEngine's expression language should be easy to extend and improve with new features.

This multiple-pass architecture may have disadvantages:

* One man's *clean, well-factored design*, is another man's *[lasanga code](http://en.wikipedia.org/wiki/Spaghetti_code#Lasagna_code "Spaghetti code - Wikipedia, the free encyclopedia")* -- too many layers.
* MGTemplateEngine (which I believe is a single-pass architecture) offers a smaller code footprint and simpler architecture. Again, if you're in the market, you should check it out too.

####Streaming output
TDTemplateEngine also uses `NSOutputStream` for output, rather than only offering an in-memory string output option. This should offer performance and memory-usage benefits for use cases where rendering a template produces large text output at runtime.

The downside of streaming output is that the simple *render-to-in-memory-string* use case is slightly more complex (but only slightly).

###Template Syntax

TDTemplateEngine template syntax is very similar to MGTemplateEngine and Django. Tag delimiters like `{{` `}}` and `{%` `%}` are easily configurable.

####Print Tag

**Print Tags** print the value an expression to the text output:

     My name is {{name}}.

Builtin **Filters** are available:

     My name is {{firstName|capitalize}} {{lastName|capitalize}}, and I'm a {{profession|lowercase}}.

     Mah kitteh sez "{{lolSpeak|trim|uppercase}}".

     {{'Hello World!'|replace:'hello', 'Goodbye Cruel', 'i'}}"

     {{'now'|dateFormat:'EEE, MMM d, yy'}}

####Filter Extensibility

You can define your own Filters in ObjC by subclassing `TDFilter` and overriding `-[TDFilter doFilter:withArguments:]`.

####If Tag

**If Tags** offer conditional rendering based on input variables at render time:

    {% if testVal <= expectedMax || force %}
        Text 1.
    {% elif shortCircuit or ('foo' == bar and 'baz' != bat) %}
        Text 2.
    {% else %}
        Default Text.
    {% /if %}

*(Note the boolean test expressions in this example are nonsense, and just intended to demonstrate some of the expression language features.)*

####For Tag

**For Tags** can loop thru arbitrary numerical ranges, and may nest:

    {% for i in 0 to 10 %}
        {% for j in 0 to 2 %}
            {{i}}:{{j}}
        {% /for %}
    {% /for %}

Numerical ranges may iterate in reverse order, and also offer a "step" option specified after the `by` keyword

    {% for i in 70 to 60 by 2 %}
        {{i}}{% if not currentLoop.isLast %},{% /if %}
    {% /for %}
    
Prints:

    70,68,66,64,62,60

Note that each For Tag offers access to a `currentLoop` variable which provides information like `currentIndex`, `isFirst`, `isLast`, and `parentLoop`.

For Tags can also loop thru variables representing Cocoa collection objects like `NSArray`, or `NSSet`:

    {% for obj in vec %}
        {{obj}}
    {% /for %}

and `NSDictionary` (note the convenient unpacking of *both key and value*):

    {% for key, val in dict %}
        {{key}}:{{val}}
    {% /for %}

####Continue Tag

**Continue Tags** can be used to skip the remainder of the current iteration of a For Tag loop. 

Continue Tags are are similar to the `continue` statement in most C-inspired languages (like JavaScript, Java, C++, ObjC, etc) with one important enhancement.

Continue Tags may contain an optional boolean expression. If the expression evaluates true, the Continue Tag is respected, and the remainder of the current For Tag iteration is skipped. However, if the expression evaluates false, the continue tag is otherwise ignored, and the current iteration of the For Tag carries on as normal.

The expression within the Continue Tag is essentially a syntactical short cut. The two following forms are semantically equivalent, but the second is more convenient:

    {% for i in 1 to 3 %}
        {% if i == 2 %}
            {% continue %}
        {% /if %}
        {{i}}
    {% /if %}

    {% for i in 1 to 3 %}
        {% continue i == 2 %}
        {{i}}
    {% /if %}

Both examples produce the following output:

    13

If no expression is present in the Continue Tag, it is always respected, and the current iteration of the For Tag is always skipped.

####Tag Extensibility

You can implement your own custom Tags by subclassing `TDTag` and overriding `-[TDTag doTagInContext:]`.

###Template Expression Language

As you have seen in the examples above, many tags may contain simple expressions which should be familiar to anyone with experience using JavaScript.

###Objective-C API Usage

Create a `TDTemplateEngine` object and render a template in two distinct phases: (compile and render) to an `NSOutputStream`:

    // create an engine
    TDTemplateEngine *eng = [TDTemplateEngine templateEngine];
    
    // compile the template at a given file path to an AST
    NSError *err = nil;
    TDNode *tree = [eng compileTemplateFile:path encoding:NSUTF8StringEncoding error:&err];
    
    // provide a streaming output destination
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    
    // establish runtime template variable values
    id vars = @{@"foo": @"bar"};
    
    // render tree to template text
    err = nil;
    [eng renderTemplateTree:tree withVariables:vars toStream:stream error:&err];

Or use the convenience API for compile+render via one method call:

    TDTemplateEngine *eng = [TDTemplateEngine templateEngine];
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    
    NSError *err = nil;
    BOOL success = [eng processTemplateString:input withVariables:vars toStream:stream error:&err];
    NSString *output = [[[NSString alloc] initWithData:[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:NSUTF8StringEncoding] autorelease];

###Threading Considerations

**The `TDTemplateEngine` class is *NOT* thread-safe**. Each `TDTemplateEngine` object must be created on and receive messages on *only one thread*. However, this need not be the main thread. It may be done on a background thread if you like. In fact, it's probably best to restrict creation and usage of a `TDTemplateEngine` object to a **background** thread.
