//
//  ObjcUnit.h
//  ObjcUnit
//
//  Created by Malte Tancred on 2013-03-06.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestSuite : NSObject
//@property(copy) id (^suiteSetup)(void);
//@property(copy) void (^suiteTearDown)(id);
@property(copy) NSString *name;
@property(copy) id (^setup)(void);
@property(copy) void (^tearDown)(id fixture);
@property(assign) BOOL runTestsSequentially;
@property(assign) BOOL runSuiteSequentially;
@property(strong,readonly) NSMutableDictionary *tests;
- (void)add:(NSString *)testName test:(void (^)(id fixture))testCase;
+ (NSArray *)collectSuites;
@end

@interface TestSuite (Assertions)
// assertions
+ (void)assertInt:(int)actual equals:(int)expected;
+ (void)assertUint64:(uint64_t)actual equals:(uint64_t)expected;
+ (void)assertUint32:(uint32_t)actual equals:(uint32_t)expected;
+ (void)assertUint16:(uint16_t)actual equals:(uint16_t)expected;
+ (void)assertUint8:(uint8_t)actual equals:(uint8_t)expected;
+ (void)assertNSUInteger:(NSUInteger)actual equals:(NSUInteger)expected;

+ (void)assertNil:(id)actual;
+ (void)assertNothing:(id)actual;
+ (void)assert:(id)actual equals:(id)expected;
+ (void)assert:(id)actual sameAs:(id)expected;
@end


@interface AssertionFailure : NSException
@end


@interface TestCollector : NSObject
@property(strong) NSArray *testSuites;
- (void)collectTestSuites;
@end


@interface TestRunner : NSObject
@property(strong) NSOperationQueue *parallel;
@property(strong) NSOperationQueue *serial;
- (void)runTests:(NSArray *)testSuites;
- (void)runTestSuite:(TestSuite *)aSuite;
@end
