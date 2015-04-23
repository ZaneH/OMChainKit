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
//	_exampleWallet = [[OMChainWallet alloc] initWithUsername:@"username"
//													password:@"password"
//													 success:^(OMChainWallet *wallet) {
//														 
//													 } failure:^(OMChainWallet *wallet, NSString *error) {
//														 
//													 }];
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
	
	switch (indexPath.row) {
		case 0: {
			[_exampleWallet omcGetInfoWithCompletionHandler:^(NSDictionary *info) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:info.description delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 1: {
			[_exampleWallet omcGetBalanceWithAddress:@"" completionHandler:^(NSString *address, double balance) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Address: %@\nBalance: %f", address, balance] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 2: {
			[_exampleWallet omcCheckAddressWithAddress:@"oTrArkBbBdsRTAGbher1X9ZmhnHZjMnM1k" completionHandler:^(NSString *address, BOOL isValid) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Address: %@\nisValid: %d", address, isValid] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 3: {
			[_exampleWallet omcVerifyMessageWithAddress:@"oTrArkBbBdsRTAGbher1X9ZmhnHZjMnM1k" message:@"Created by ZaneH" signature:@"Fake Signature" completionHandler:^(NSString *address, NSString *message, NSString *signature, BOOL isVerified) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Address: %@\nMessage: %@\nSignature: %@\nisVerified: %d", address, message, signature, isVerified] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 4: {
			[_exampleWallet omcGetRichListWithCompletionHandler:^(NSArray *richList) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Rich List: %@", richList.description] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 5: {
			[_exampleWallet omcGetStatsWithCompletionHandler:^(NSDictionary *stats) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Stats: %@", stats.description] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
			break;
		}
		case 6: {
			[_exampleWallet omcCalculateEarningsWithHashrate:34 completionHandler:^(double hashrate, double difficulty, NSDictionary *data) {
				[[[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"Hashrate: %f\nDifficulty: %f\nData: %@", hashrate, difficulty, data] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
			}];
		}
		default: {
			break;
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _methods.count;
}

- (void)omnichainFailedWithWallet:(OMChainWallet *)wallet error:(NSString *)error {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An unexpected error occured when attempting: %@", error] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil] show];
}

@end