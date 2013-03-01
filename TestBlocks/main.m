//
//  main.m
//  TestBlocks
//
//  Created by Malte Tancred on 2013-02-28.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestSuite : NSObject
//@property(copy) id (^suiteSetup)(void);
//@property(copy) void (^suiteTearDown)(id);
@property(copy) NSString *name;
@property(copy) id (^setup)(void);
@property(copy) void (^tearDown)(id);
@property(assign) BOOL runTestsSequentially;
@property(strong,readonly) NSMutableDictionary *tests;
- (void)add:(NSString *)testName test:(void (^)(id))testCase;
+ (NSArray *)collectSuites;
@end

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		// Test suite class: instance with setup and tear down blocks; set or array with test blocks
		//   (if) setup returns fixture object, passed to test and tear down blocks
		//   suite can have setup and tear down blocks run once for suite too.
		//   named test blocks.
		// Assertion methods (or blocks?)
	    // Test collector: find all test suite classes, report all test names (and setup tear down?)
		// Test runner:
		//   Run set in parallell, run array in serial
		//   Specify in suite if run in separate processes
		//   Option to run everything serially
		//   Option to run each test in separate process or all in same
		//   Catch exceptions and report
		//   Report results
		// How do we handle crashes? How do we find out what thread crashed and is it even interesting?
	    NSLog(@"Hello, World!");
	}
    return 0;
}


@implementation TestSuite

- (id)init {
	if (!(self = [super init])) return nil;
	self.name = NSStringFromClass([self class]);
	_tests = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)add:(NSString *)testName test:(void (^)(id))testCase {
	[_tests setObject:testCase forKey:testName];
}

+ (NSArray *)collectSuites {
	return @[];
}

@end