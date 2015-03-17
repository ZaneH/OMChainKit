//
//  ViewController.m
//  OMChainKit
//
//  Created by Zane Helton on 3/14/15.
//  Copyright (c) 2015 ZaneHelton. All rights reserved.
//

#import "OMChainDemoTableViewController.h"

@interface OMChainDemoTableViewController () {
	OMChainWallet *_exampleWallet;
	NSArray *_methods;
	NSArray *_descriptions;
}

@end

@implementation OMChainDemoTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_methods = @[@"getinfo",
				 @"getbalance",
				 @"checkaddress",
				 @"verifymessage",
				 @"getrichlist",
				 @"getwstats",
				 @"earningscalc",
				 @"wallet_register",
				 @"wallet_login",
				 @"wallet_getinfo",
				 @"wallet_genaddr",
				 @"wallet_send",
				 @"wallet_signmessage",
				 @"wallet_changepassword",
				 @"wallet_changeemail"];
	
	_descriptions = @[@"Returns misc information like difficulty, mining speed, and average block time",
					  @"Returns the value of an Omnicoin address",
					  @"A BOOL saying whether it's a real address or not",
					  @"Returns whether the specified signature is as valid hash for the specified message for the specified address",
					  @"Returns data for generating the richlist on https://omnicha.in/richlist/",
					  @"Returns total users and total balance of all online wallet accounts",
					  @"Retuns the amount of OMC that will be mined with the specified hashrate",
					  @"Registers a new account with Omnicha.in",
					  @"Initializes a new wallet",
					  @"Fills in the wallet properties",
					  @"Generates a new Omnicoin address",
					  @"Sends Omnicoin to an address",
					  @"Signs a message with the specified address",
					  @"Changes the users password",
					  @"Changes the users email address"];
	
	// initialize with username and password to login automatically
	_exampleWallet = [[OMChainWallet alloc] init];
	// also make sure you add a delegate if you want anything to actually work
	[_exampleWallet setDelegate:self];
	
	// Like this!
	//_exampleWallet = [[OMChainWallet alloc] initWithUsername:@"username"
	//												password:@"password"
	//												delegate:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"methodCell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:@"methodCell"];
	}
	
	cell.textLabel.text = _methods[indexPath.row];
	cell.detailTextLabel.text = _descriptions[indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row > 6) {
		[[[UIAlertView alloc] initWithTitle:@"(disabled)"
									message:@"All wallet functions are disabled on the demo. They can't be displayed in alert views like this."
								   delegate:self
						  cancelButtonTitle:@"Dismiss"
						  otherButtonTitles:nil] show];
		return;
	}
	
	if (indexPath.row == 0) {
		[_exampleWallet omcGetInfo];
	} else if (indexPath.row == 1) {
		[_exampleWallet omcGetBalanceWithAddress:@"oTrArkBbBdsRTAGbher1X9ZmhnHZjMnM1k"];
	} else if (indexPath.row == 2) {
		[_exampleWallet omcCheckAddressWithAddress:@"oTrArkBbBdsRTAGbher1X9ZmhnHZjMnM1k"];
	} else if (indexPath.row == 3) {
		[_exampleWallet omcVerifyMessageWithAddress:@"oTrArkBbBdsRTAGbher1X9ZmhnHZjMnM1k" message:@"Blank" signature:@"This is an invalid signature!"];
	} else if (indexPath.row == 4) {
		[_exampleWallet omcGetRichList];
	} else if (indexPath.row == 5) {
		[_exampleWallet omcGetStats];
	} else if (indexPath.row == 6) {
		// you obviously shouldn't hardcode hashrate nor difficulty. omcGetInfo can get difficulty for you and your users can provide the hashrate in MH/s
		[_exampleWallet omcCalculateEarningsWithHashrate:1 difficulty:15.392378990565];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _methods.count;
}

- (void)omnichainSucceededWithWallet:(OMChainWallet *)wallet method:(NSString *)method {
	NSLog(@"%@ called", method);
}

- (void)gotBalanceFromOmnichainWithAddress:(NSString *)address balance:(double)balance {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Address: %@\nBalance: %f", address, balance]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotCalculatedEarningsFromOmnichainWithHashrate:(double)hashrate difficulty:(double)difficulty data:(NSDictionary *)data {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Hashrate: %f\nDifficulty: %f\nData: %@", hashrate, difficulty, data]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotInfoFromOmnichainSuccessfullyWithData:(NSDictionary *)data {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Data: %@", data]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotIsValidAddressFromOmnichainWithAddress:(NSString *)address isValidAddress:(BOOL)isValidAddress {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Address: %@\nisValid: %@", address, (double)isValidAddress == 0 ? @"NO" : @"YES"]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotIsValidSignedAddressWithAddress:(NSString *)address message:(NSString *)message signature:(NSString *)signature isVerified:(BOOL)isVerified {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Address: %@\nMessage: %@\nSignature: %@\nisVerified: %@", address, message, signature, (double)isVerified == 0 ? @"NO" : @"YES"]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotRichListFromOmnichainWithData:(NSArray *)data {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Data: %@", [data description]]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)gotStatsFromOmnichainWithData:(NSDictionary *)data {
	[[[UIAlertView alloc] initWithTitle:@"Success"
								message:[NSString stringWithFormat:@"Data: %@", data]
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

- (void)omnichainFailedWithWallet:(OMChainWallet *)wallet error:(NSString *)error {
	[[[UIAlertView alloc] initWithTitle:@"Error"
								message:error
							   delegate:self
					  cancelButtonTitle:@"Dismiss"
					  otherButtonTitles:nil] show];
}

@end