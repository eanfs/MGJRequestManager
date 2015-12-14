//
//  STRequestManagerDemoTests.m
//  STRequestManagerDemoTests
//
//  Created by limboy on 3/18/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "STRequestManager.h"

@interface STRequestManagerDemoTests : XCTestCase

@end

@implementation STRequestManagerDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGETRequest {
    XCTestExpectation *expection = [self expectationWithDescription:@"Test GET Request"];
    
    [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:@{@"foo": @"bar"} startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        XCTAssert([result[@"args"][@"foo"] isEqualToString:@"bar"]);
        XCTAssert(error == nil);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.f handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error:%@", error);
        }
    }];
}

- (void)testPOSTRequest {
    XCTestExpectation *expection = [self expectationWithDescription:@"Test POST Request"];
    
    [[STRequestManager sharedInstance] POST:@"http://httpbin.org/post" parameters:@{@"foo": @"bar"} startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        XCTAssert([result[@"form"][@"foo"] isEqualToString:@"bar"]);
        XCTAssert(error == nil);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.f handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error:%@", error);
        }
    }];
}

- (void)testChainRequest {
    XCTestExpectation *expection = [self expectationWithDescription:@"Test Chain Request"];
    
    static BOOL FirstRequestFinished = NO;
    
    AFHTTPRequestOperation *operation1 = [[STRequestManager sharedInstance] GET:@"http://httpbin.org/delay/2" parameters:nil startImmediately:NO configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        XCTAssert(error == nil);
        FirstRequestFinished = YES;
    }];
    
    AFHTTPRequestOperation *operation2 = [[STRequestManager sharedInstance] GET:@"http://httpbin.org/get" parameters:@{@"foo": @"bar"} startImmediately:NO configurationHandler:nil completionHandler:^(NSError *error, NSDictionary *result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        XCTAssert([result[@"args"][@"foo"] isEqualToString:@"bar"]);
        XCTAssert(FirstRequestFinished);
        XCTAssert(error == nil);
        [expection fulfill];
    }];
    
    [[STRequestManager sharedInstance] addOperation:operation1 toChain:@"chain"];
    [[STRequestManager sharedInstance] addOperation:operation2 toChain:@"chain"];
    
    [self waitForExpectationsWithTimeout:5.f handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error:%@", error);
        }
    }];
}

@end
