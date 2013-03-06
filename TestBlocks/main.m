//
//  main.m
//  TestBlocks
//
//  Created by Malte Tancred on 2013-02-28.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjcUnit/ObjcUnit.h>

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		// Test suite class: instance with setup and tear down blocks; set or array with test blocks
		//   (if) setup returns fixture object, passed to test and tear down blocks
		//   suite can have setup and tear down blocks run once for suite too. (Suite fixture passed to tests too? Always use varargs args for test blocks?)
		//   named test blocks.
		// Assertion methods (or blocks?)
	    // Test collector: find all test suite classes, report all test names (and setup tear down?)
		// Test runner:
		//   Run in parallell by default, run sequentially on request
		//   Run tests suite by suite?
		//   Specify in suite if run in separate processes
		//   Option to run everything serially
		//   Option to run each test in separate process or all in same
		//   Catch exceptions and report; failure on AssertionFailure, error on everything else.
		//   Report results
		// How do we handle crashes? How do we find out what thread crashed and is it even interesting?
		TestCollector *collector = [[TestCollector alloc] init];
		[collector collectTestSuites];
		NSLog(@"collected test suites: %@", [collector.testSuites valueForKey:@"name"]);

		TestRunner *runner = [[TestRunner alloc] init];
		[runner runTests:collector.testSuites];

		// exit status = test result status
	}
    return 0;
}


@interface Parallel : TestSuite
@end
@implementation Parallel
+ (NSArray *)collectSuites {
	Parallel *suite = [[Parallel alloc] init];
	for (int i=0; i<20; i++) {
		[suite add:[NSString stringWithFormat:@"test%d", i] test:^(id fixture) {
			for (int x = 0; x<100000000; x++) { int y=x*x; y--; }
		}];
	}
	return @[suite];
}
@end


@interface Sequential : TestSuite
@end
@implementation Sequential
+ (NSArray *)collectSuites {
	Sequential *suite = [[Sequential alloc] init];
	suite.runTestsSequentially = YES;
	suite.runSuiteSequentially = YES;
	for (int i=0; i<10; i++) {
		[suite add:[NSString stringWithFormat:@"otest%d", i] test:^(id fixture) {
			for (int x = 0; x<100000000; x++) { int y=x*x; y--; }
		}];
	}
	[suite add:@"seq test that will fail" test:^(id fixture) {
		[self assertInt:3 equals:4];
	}];
	return @[suite];
}

@end
