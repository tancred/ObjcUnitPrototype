//
//  SuiteTests.m
//  TestBlocks
//
//  Created by Malte Tancred on 2013-03-06.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import "SuiteTests.h"
#import <ObjcUnit/ObjcUnit.h>

@implementation SuiteTests
@end


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
