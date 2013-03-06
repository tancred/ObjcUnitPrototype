//
//  main.m
//  unittester
//
//  Created by Malte Tancred on 2013-03-06.
//  Copyright (c) 2013 Tancred. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjcUnit/ObjcUnit.h>

static void DieUsage(NSString *msg) {
	if (msg) fprintf(stderr, "FATAL: %s\n", [msg UTF8String]);
	fprintf(stderr, "Usage: %s <bundle_path>\n", [[[NSProcessInfo processInfo] processName] UTF8String]);
	exit(1);
}

int main(int argc, const char * argv[])
{
	@autoreleasepool {
		if (argc < 2) DieUsage(nil);
		NSString *bundlePath = [[NSProcessInfo processInfo] arguments][1];
		NSBundle *testBundle = [NSBundle bundleWithPath:bundlePath];
		if (!testBundle) DieUsage([NSString stringWithFormat:@"unable to find bundle: %@", bundlePath]);
		
		NSError *error = nil;
		if (![testBundle loadAndReturnError:&error]) {
			DieUsage([NSString stringWithFormat:@"error loading bundle at path %@: %@", bundlePath, [error localizedDescription]]);
		}

		TestCollector *collector = [[TestCollector alloc] init];
		[collector collectTestSuites];
		NSLog(@"collected test suites: %@", [collector.testSuites valueForKey:@"name"]);
		
		TestRunner *runner = [[TestRunner alloc] init];
		[runner runTests:collector.testSuites];
	}
    return 0;
}
