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


@interface MyTest : TestSuite
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
		//   Run set in parallell, run array in serial
		//   Specify in suite if run in separate processes
		//   Option to run everything serially
		//   Option to run each test in separate process or all in same
		//   Catch exceptions and report
		//   Report results
		// How do we handle crashes? How do we find out what thread crashed and is it even interesting?
		TestCollector *collector = [[TestCollector alloc] init];
		[collector collectTestSuites];
		NSLog(@"collected test suites: %@", [collector.testSuites valueForKey:@"name"]);
	}
    return 0;
}


@implementation MyTest
+ (NSArray *)collectSuites {
	MyTest *suite = [[MyTest alloc] init];
	return @[suite];
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