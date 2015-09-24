//
//  OMChainKitTests.m
//  OMChainKitTests
//
//  Created by Zane Helton on 3/14/15.
//  Copyright (c) 2015 ZaneHelton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OMChainWallet.h"

@interface OMChainKitTests : XCTestCase

@property (nonatomic, strong) OMChainWallet *blankWallet;

@end

@implementation OMChainKitTests

- (void)setUp {
    [super setUp];
	_blankWallet = [[OMChainWallet alloc] init];
}

- (void)test_blankWallet_hasBlankValues {
	XCTAssert([self.blankWallet.username isEqualToString:@""]);
	XCTAssert([self.blankWallet.passwordHash isEqualToString:@""]);
	XCTAssert([self.blankWallet.emailAddress isEqualToString:@""]);
	
	XCTAssert(self.blankWallet.transactions.count == 0);
	XCTAssert(self.blankWallet.addresses.count == 0);
	
	XCTAssert(self.blankWallet.transactionsIn == 0);
	XCTAssert(self.blankWallet.transactionsOut == 0);
	XCTAssert(self.blankWallet.totalIn == 0);
	XCTAssert(self.blankWallet.totalOut == 0);
	XCTAssert(self.blankWallet.balance == 0);
	XCTAssert(self.blankWallet.pendingBalance == 0);
	XCTAssert(self.blankWallet.version == 0);
}

- (void)test_walletSignIn_isError {
	_blankWallet = [[OMChainWallet alloc] initWithUsername:@"blank" password:@"blank"];
	[_blankWallet attemptSignInWithSuccess:^{
		XCTFail("Shouldn't pass.");
	} failed:^(OMChainWallet *wallet, NSString *error) {
		XCTAssert([error isEqualToString:@"BAD_LOGIN"]);
	}];
}

- (void)tearDown {
    [super tearDown];
}

@end
