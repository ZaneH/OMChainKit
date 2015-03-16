//
//  ViewController.m
//  OMChainKit
//
//  Created by Zane Helton on 3/14/15.
//  Copyright (c) 2015 ZaneHelton. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
	OMChainWallet *_exampleWallet;
}

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_exampleWallet = [[OMChainWallet alloc] initWithUsername:@"Varosion" password:@"ThisTest!" delegate:self];
}

- (void)omnichainFailedWithWallet:(OMChainWallet *)wallet error:(NSString *)error {
	if ([error isEqualToString:@"BAD_LOGIN"]) {
		[[[UIAlertView alloc] initWithTitle:@"Failed"
									message:@"Username or password is wrong"
								   delegate:self
						  cancelButtonTitle:@"Dismiss"
						  otherButtonTitles:nil] show];
	} else if ([error isEqualToString:@"IP_BANNED"]) {
		[[[UIAlertView alloc] initWithTitle:@"Failed"
									message:@"Your IP is banned from this service"
								   delegate:self
						  cancelButtonTitle:@"Dismiss"
						  otherButtonTitles:nil] show];
	}
}

- (void)omnichainSucceededWithWallet:(OMChainWallet *)wallet method:(NSString *)method {
	if ([method isEqualToString:@"wallet_login"]) {
		[[[UIAlertView alloc] initWithTitle:@"Success!"
									message:[NSString stringWithFormat:@"Version: %@", wallet.version]
								   delegate:self
						  cancelButtonTitle:@"Dismiss"
						  otherButtonTitles:nil] show];	
	}
}

@end