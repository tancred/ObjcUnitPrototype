//
//  main.m
//  TestBlocks
//
//  Created by Malte Tancred on 2013-02-28.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>


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


@interface TestCollector : NSObject
@property(strong) NSArray *testSuites;
- (void)collectTestSuites;
@end


@interface TestRunner : NSObject
- (void)runTests:(NSArray *)testSuites;
- (void)runTestSuite:(TestSuite *)aSuite;
@end


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
		//   Catch exceptions and report
		//   Report results
		// How do we handle crashes? How do we find out what thread crashed and is it even interesting?
		TestCollector *collector = [[TestCollector alloc] init];
		[collector collectTestSuites];
		NSLog(@"collected test suites: %@", [collector.testSuites valueForKey:@"name"]);

		TestRunner *runner = [[TestRunner alloc] init];
		[runner runTests:collector.testSuites];

		// exit when done (but doesn't wait for the parallel tests though)
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"exiting");
			exit(0);
		});

		dispatch_main();
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
	for (int i=0; i<10; i++) {
		[suite add:[NSString stringWithFormat:@"otest%d", i] test:^(id fixture) {
			for (int x = 0; x<100000000; x++) { int y=x*x; y--; }
		}];
	}
	return @[suite];
}
@end


@implementation TestRunner

- (void)runTests:(NSArray *)testSuites {
	for (TestSuite *each in testSuites) {
		[self runTestSuite:each];
	}
}

- (void)runTestSuite:(TestSuite *)aSuite {
	@autoreleasepool {
		NSLog(@"Running test suite %@ sequantially %@", aSuite.name, aSuite.runTestsSequentially ? @"YES" : @"NO");
		dispatch_queue_t queue = aSuite.runTestsSequentially ? dispatch_get_main_queue() : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
		[aSuite.tests enumerateKeysAndObjectsUsingBlock:^(id testName, void (^test)(id), BOOL *stop) {
			NSLog(@"Scheduling %@-%@", aSuite.name, testName);
			dispatch_async(queue, ^{
				@autoreleasepool {
					id fixture = nil;
					id setupFailure = nil;
					id testFailure = nil;
					id tearDownFailure = nil;

					@try {
						if (aSuite.setup) {
							NSLog(@"%@-%@: setup", aSuite.name, testName);
							fixture = aSuite.setup();
						}
					}
					@catch (NSException *exception) {
						setupFailure = exception;
					}

					@try {
						if (!setupFailure) {
							NSLog(@"%@-%@: test", aSuite.name, testName);
							test(fixture);
						}
					}
					@catch (NSException *exception) {
						testFailure = exception;
					}

					@try {
						if (aSuite.tearDown) {
							NSLog(@"%@-%@: tear down", aSuite.name, testName);
							aSuite.tearDown(fixture);
						}
					}
					@catch (NSException *exception) {
						tearDownFailure = exception;
					}
					if (setupFailure) NSLog(@"%@-%@: setup failed: %@", aSuite.name, testName, setupFailure);
					if (testFailure) NSLog(@"%@-%@: test failed: %@", aSuite.name, testName, testFailure);
					if (tearDownFailure) NSLog(@"%@-%@: tear down failed: %@", aSuite.name, testName, tearDownFailure);
					NSLog(@"%@-%@: test finished", aSuite.name, testName);
				}
			});
		}];
	}
}

@end

@implementation TestCollector

static BOOL IsKindOfClass(Class who, Class kind) {
	if (!who) return NO;
	if (!kind) return class_getSuperclass(who) == Nil;
	Class cls = who;
	while (cls != Nil) {
		if (cls == kind) { NSLog(@"%@ is subclass of %@", NSStringFromClass(who), NSStringFromClass(kind)); return YES; }
		cls = class_getSuperclass(cls);
	}
	return NO;
}

static BOOL IsSubclassOf(Class who, Class super) {
	if (!who) return NO;
	if (!super) return class_getSuperclass(who) == Nil;
	Class cls = who;
	while ((cls = class_getSuperclass(cls)) != Nil) {
		if (cls == super) { NSLog(@"%@ is subclass of %@", NSStringFromClass(who), NSStringFromClass(super)); return YES; }
	}
	return NO;
}

- (void)collectTestSuites {
	NSMutableArray *collected = [NSMutableArray array];
	unsigned int count = 0;
	Class *classes = objc_copyClassList(&count);
	for (unsigned int i=0; i<count; i++) {
		Class cls = classes[i];
		if (IsSubclassOf(cls, [TestSuite class])) {
			NSArray *suites = [cls collectSuites];
			if (!suites || [suites count] == 0) {
				NSLog(@"No suites from %@", NSStringFromClass(cls));
			}
			if (suites) [collected addObjectsFromArray:suites];
		}
	}
	self.testSuites = collected;
}

@end


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