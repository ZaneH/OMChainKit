//
//  OMChainWallet.m
//  OMChainKit
//
//  Created by Zane Helton on 3/15/15.
//  Copyright (c) 2015 ZaneHelton. All rights reserved.
//

#import "OMChainWallet.h"

@implementation OMChainWallet {
	NSString *_potentialEmail;
	NSString *_potentialPassword;
	
	// Used for the signed message delegate
	NSString *_tempAddress;
	NSString *_tempMessage;
	NSString *_tempSignature;
	
	double _tempHashrate;
	double _tempDifficulty;
	
	NSTimeInterval _timeOutInterval;
}

#pragma mark - Initializers

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password delegate:(id<OMChainDelegate>)delegate {
	self = [super init];
	if (self) {
		self.username = username;
		self.passwordHash = [self createSHA512WithString:password];
		self.delegate = delegate;
		_timeOutInterval = 60;

		[self createAPIRequestWithMethod:@"wallet_login"
								  params:@{@"username":self.username,
										   @"password":self.passwordHash}];
	}
	return self;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.username = @"";
		self.passwordHash = @"";
		self.emailAddress = @"";
		self.transactions = [NSMutableArray new];
		self.addresses = [NSMutableArray new];
		self.transactionsIn = 0;
		self.transactionsOut = 0;
		self.totalIn = 0;
		self.totalOut = 0;
		self.balance = 0;
		self.pendingBalance = 0;
		self.version = 0;
		_timeOutInterval = 60;
	}
	return self;
}

#pragma mark -

#pragma mark - Get Info Methods

- (void)getWalletInfo {
	[self createAPIRequestWithMethod:@"wallet_getinfo"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken}];
}

#pragma mark -

#pragma mark - Configuration Methods

- (void)setTimout:(NSUInteger)timeOut {
	_timeOutInterval = timeOut;
}

#pragma mark - Mostly Statistics API Interaction Method Declarations

- (void)omcGetInfo {
	[self createAPIRequestWithMethod:@"getinfo"
							  params:@{}];
}

- (void)omcGetBalanceWithAddress:(NSString *)address {
	_tempAddress = address;
	[self createAPIRequestWithMethod:@"getbalance"
							  params:@{@"address":address}];
}

- (void)omcCheckAddressWithAddress:(NSString *)address {
	_tempAddress = address;
	[self createAPIRequestWithMethod:@"checkaddress"
							  params:@{@"address":address}];
}

- (void)omcVerifyMessageWithAddress:(NSString *)address message:(NSString *)message signature:(NSString *)signature {
	_tempAddress = address;
	_tempSignature = signature;
	_tempMessage = message;
	[self createAPIRequestWithMethod:@"verifymessage"
							  params:@{@"address":address,
									   @"message":message,
									   @"signature":signature}];
}

- (void)omcGetRichList {
	[self createAPIRequestWithMethod:@"getrichlist"
							  params:@{}];
}

- (void)omcGetStats {
	[self createAPIRequestWithMethod:@"getwstats"
							  params:@{}];
}

- (void)omcCalculateEarningsWithHashrate:(double)hashrate {
	_tempHashrate = hashrate;
	[self createAPIRequestWithMethod:@"earningscalc"
							  params:@{@"hashrate":[NSNumber numberWithDouble:hashrate]}];
}

- (void)omcCalculateEarningsWithHashrate:(double)hashrate difficulty:(double)difficulty {
	_tempHashrate = hashrate;
	_tempDifficulty = difficulty;
	[self createAPIRequestWithMethod:@"earningscalc"
							  params:@{@"hashrate":[NSNumber numberWithDouble:hashrate],
									   @"difficulty":[NSNumber numberWithDouble:difficulty]}];
}

#pragma mark -

#pragma mark - API Interaction Methods

- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password {
	[self registerAccountWithUsername:username password:password confirmPassword:password];
}

- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword {
	[self createAPIRequestWithMethod:@"wallet_register"
							  params:@{@"username":username,
									   @"password":[self createSHA512WithString:password],
									   @"passwordConfirm":[self createSHA512WithString:confirmPassword]}];
}

- (void)changeEmailForAccountWithNewEmail:(NSString *)email {
	_potentialEmail = email;
	[self createAPIRequestWithMethod:@"wallet_changeemail"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken,
									   @"email":self.emailAddress}];
}

- (void)changePasswordForAccountWithNewPassword:(NSString *)password {
	[self changePasswordForAccountWithNewPassword:password confirmPassword:password];
}

- (void)changePasswordForAccountWithNewPassword:(NSString *)password confirmPassword:(NSString *)confirmPassword {
	_potentialPassword = [self createSHA512WithString:password];
	
	// client-side checking
	if ([password isEqualToString:@""] || [confirmPassword isEqualToString:@""]) {
		[self.delegate omnichainFailedWithWallet:self error:@"EMPTY_REQUIRED_FIELDS"];
		return;
	}
	if (![password isEqualToString:confirmPassword]) {
		[self.delegate omnichainFailedWithWallet:self error:@"NONMATCHING_PASSWORDS"];
		return;
	}
	
	// if everything's alright on the client-side, send the request
	[self createAPIRequestWithMethod:@"wallet_changepassword"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken,
									   @"password_new":[self createSHA512WithString:password],
									   @"password_new_confirm":[self createSHA512WithString:confirmPassword]}];
}

- (void)signMessageWithAddress:(NSString *)address message:(NSString *)message {
	_tempAddress = address;
	_tempMessage = message;
	[self createAPIRequestWithMethod:@"wallet_signmessage"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken,
									   @"address":address,
									   @"message":message}];
}

- (void)importPrivateKeyWithKey:(NSString *)privateKey address:(NSString *)address {
	[self createAPIRequestWithMethod:@"wallet_importkey"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken,
									   @"address":address,
									   @"privkey":privateKey}];
}

- (void)sendOmnicoinToAddress:(NSString *)address amount:(double)amount {
	[self createAPIRequestWithMethod:@"wallet_send"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken,
									   @"address":address,
									   @"amount":[NSNumber numberWithDouble:amount]}];
}

- (void)generateNewAddress {
	[self createAPIRequestWithMethod:@"wallet_genaddr"
							  params:@{@"username":self.username,
									   @"password":self.sessionToken}];
}

#pragma mark -

#pragma mark - Helper Methods

- (NSString *)createSHA512WithString:(NSString *)source {
	const char *s = [source cStringUsingEncoding:NSASCIIStringEncoding];
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
	CC_SHA512(keyData.bytes, (int)keyData.length, digest);
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
	
	// If you have a better method to do this please create a pull request. This is just sad.
	// stringValue returns (null) so this is all I could think of.
	return [[[[out description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
}

- (void)createAPIRequestWithMethod:(NSString *)method params:(NSDictionary *)params {
	NSArray *keys = [params allKeys];
	NSArray *values = [params allValues];
	NSString *requestString = @"";
	for (int keyIndex = 0; keyIndex < keys.count; keyIndex++) {
		requestString = [requestString stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", keys[keyIndex], values[keyIndex]]];
	}
	
	NSURL *requestURL = [NSURL URLWithString:[[NSString stringWithFormat:@"https://omnicha.in/api?method=%@%@", method, requestString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *callMethodRequest = [[NSMutableURLRequest alloc]
											  initWithURL:requestURL
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:_timeOutInterval];
	[callMethodRequest setHTTPMethod:@"GET"];
	__unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:callMethodRequest delegate:self];
}

#pragma mark -

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// sets session token & checks login
	NSString *methodSubString = connection.currentRequest.URL.query.length >= 19 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 19)] : @"";
	if ([methodSubString isEqualToString:@"method=wallet_login"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			self.sessionToken = [[jsonObject valueForKey:@"response"] valueForKey:@"session"];
			self.version = [jsonObject valueForKey:@"version"];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_login"];
		[self getWalletInfo];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 21 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 21)] : @"";
	// sets transactions out, total out, transactions in, total in, balance, pending balance, transactions, addresses, & omcUSDValue
	if ([methodSubString isEqualToString:@"method=wallet_getinfo"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			self.emailAddress = [jsonObject valueForKey:@"email"];
			
			self.transactionsOut = [[jsonObject valueForKey:@"tx_out"] integerValue];
			self.totalOut = [[jsonObject valueForKey:@"total_out"] doubleValue];
			
			self.transactionsIn = [[jsonObject valueForKey:@"tx_in"] integerValue];
			self.totalIn = [[jsonObject valueForKey:@"total_in"] doubleValue];
			
			self.balance = [[jsonObject valueForKey:@"balance"] doubleValue];
			self.pendingBalance = [[jsonObject valueForKey:@"pending_balance"] doubleValue];
			
			for (int transactionIndex = 0; transactionIndex < [[jsonObject valueForKey:@"transactions"] count]; transactionIndex++) {
				OMChainTransaction *newTransaction = [[OMChainTransaction alloc] init];
				newTransaction.date = [[[[jsonObject valueForKey:@"transactions"] objectAtIndex:transactionIndex] valueForKey:@"date"] stringValue];
				newTransaction.confirmations = [[[[jsonObject valueForKey:@"transactions"] objectAtIndex:transactionIndex] valueForKey:@"confirmations"] integerValue];
				newTransaction.transactionHash = [[[[jsonObject valueForKey:@"transactions"] objectAtIndex:transactionIndex] valueForKey:@"tx_hash"] stringValue];
				newTransaction.valueOfTransaction = [[[[jsonObject valueForKey:@"transactions"] objectAtIndex:transactionIndex] valueForKey:@"value"] integerValue];
				newTransaction.balance = [[[[jsonObject valueForKey:@"transactions"] objectAtIndex:transactionIndex] valueForKey:@"balance"] integerValue];
				
				[self.transactions insertObject:newTransaction atIndex:0];
			}
			
			for (int addressIndex = 0; addressIndex < [[jsonObject valueForKey:@"addresses"] count]; addressIndex++) {
				OMChainAddress *newAddress = [[OMChainAddress alloc] init];
				newAddress.address = [[[[jsonObject valueForKey:@"addresses"] objectAtIndex:addressIndex] valueForKey:@"address"] stringValue];
				newAddress.privateKey = [[[[jsonObject valueForKey:@"addresses"] objectAtIndex:addressIndex] valueForKey:@"private_key"] stringValue];
			}
			
			self.omcUSDValue = [[jsonObject valueForKey:@"omc_usd_price"] doubleValue];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_getinfo"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 22 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 22)] : @"";
	// creates a user on Omnicha.in
	if ([methodSubString isEqualToString:@"method=wallet_register"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_register"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 26 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 26)] : @"";
	// changes users email address
	if ([methodSubString isEqualToString:@"method=wallet_changeemail"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			// if there's an error don't update the email, otherwise do update the email address
			self.emailAddress = _potentialEmail;
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_changeemail"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 28 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 28)] : @"";
	// changes the users password
	if ([methodSubString isEqualToString:@"method=wallet_changepassword"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			// if there's an error don't update the password, otherwise do update the password
			self.passwordHash = _potentialPassword;
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_changepassword"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 25 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 25)] : @"";
	// signs a message to an address (I have no idea what this is tbh, but it was in the API and I needed to add it)
	if ([methodSubString isEqualToString:@"method=wallet_signmessage"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate signedMessageSuccessfullyWithAddress:_tempAddress message:_tempMessage signature:[[jsonObject valueForKey:@"response"] valueForKey:@"signature"]];
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_signmessage"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 23 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 23)] : @"";
	// imports a previously generated address into Omnicha.in
	if ([methodSubString isEqualToString:@"method=wallet_importkey"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_importkey"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 21 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 21)] : @"";
	// generates a new address on Omnicha.in
	if ([methodSubString isEqualToString:@"method=wallet_genaddr"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate successfullyCreatedOmnicoinAddressWithAddress:[[jsonObject valueForKey:@"response"] valueForKey:@"address"]];
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_genaddr"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= 14 ? [connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 14)] : @"";
	// returns misc information like difficulty, mining speed, and average block time
	if ([methodSubString isEqualToString:@"method=getinfo"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			NSDictionary *infoDictionary = @{@"block_count":[NSNumber numberWithInteger:[[[jsonObject valueForKey:@"response"] valueForKey:@"block_count"] integerValue]],
											 @"difficulty":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"difficulty"] doubleValue]],
											 @"netmhps":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"netmhps"] doubleValue]],
											 @"seconds_since_block":[NSNumber numberWithInteger:[[[jsonObject valueForKey:@"response"] valueForKey:@"seconds_since_block"] integerValue]],
											 @"avg_block_time_1":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"avg_block_time_1"] doubleValue]],
											 @"avg_block_time_24":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"avg_block_time_24"] doubleValue]],
											 @"total_mined_omc":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"total_mined_omc"] doubleValue]],
											 @"omc_btc_price":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"omc_btc_price"] doubleValue]],
											 @"omc_usd_price":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"omc_usd_price"] doubleValue]],
											 @"market_cap":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"market_cap"] doubleValue]],
											 @"block_reward":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"block_reward"] doubleValue]]};
			[self.delegate gotInfoFromOmnichainSuccessfullyWithData:infoDictionary];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"getinfo"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"getinfo"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=getbalance".length ?
		[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=getbalance".length)] : @"";
	// gets the balance of said wallet
	if ([methodSubString isEqualToString:@"method=getbalance"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			[self.delegate gotBalanceFromOmnichainWithAddress:_tempAddress balance:[[[jsonObject valueForKey:@"response"] valueForKey:@"balance"] doubleValue]];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"getbalance"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=checkaddress".length ?
		[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=checkaddress".length)] : @"";
	// checks if said address belongs to a valid wallet
	if ([methodSubString isEqualToString:@"method=checkaddress"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			[self.delegate gotIsValidAddressFromOmnichainWithAddress:_tempAddress isValidAddress:[[[jsonObject valueForKey:@"response"] valueForKey:@"isvalid"] boolValue]];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"checkaddress"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=verifymessage".length ?
		[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=verifymessage".length)] : @"";
	// checks if said address belongs to a valid wallet
	if ([methodSubString isEqualToString:@"method=verifymessage"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			[self.delegate gotIsValidSignedAddressWithAddress:_tempAddress message:_tempMessage signature:_tempSignature isVerified:[[[jsonObject valueForKey:@"response"] valueForKey:@"isvalid"] boolValue]];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"verifymessage"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=getrichlist".length ?
	[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=getrichlist".length)] : @"";
	// checks if said address belongs to a valid wallet
	if ([methodSubString isEqualToString:@"method=getrichlist"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			// making the rich list ( dictionaries inside an array )
			NSMutableArray *richList = [NSMutableArray new];
			for (int personIndex = 0; personIndex < [[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] count]; personIndex++) {
				NSDictionary *tempPersonDictionary = @{@"address":[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"address"],
												 @"balance":[NSNumber numberWithDouble:[[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"balance"] doubleValue]],
												 @"percent":[NSNumber numberWithDouble:[[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"percent"] doubleValue]],
												 @"rank":[NSNumber numberWithInteger:[[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"rank"] integerValue]],
												 @"usd_value":[NSNumber numberWithDouble:[[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"usd_value"] doubleValue]],
												 @"vanity_name":[[[[jsonObject valueForKey:@"response"] valueForKey:@"richlist"] objectAtIndex:personIndex] valueForKey:@"vanity_name"]};
				[richList addObject:tempPersonDictionary];
			}
			[self.delegate gotRichListFromOmnichainWithData:[NSArray arrayWithArray:richList]];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"getrichlist"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=getwstats".length ?
	[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=getwstats".length)] : @"";
	// checks if said address belongs to a valid wallet
	if ([methodSubString isEqualToString:@"method=getwstats"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			NSDictionary *statsDictionary = @{@"users":[NSNumber numberWithInteger:[[[jsonObject valueForKey:@"response"] valueForKey:@"users"] integerValue]],
											  @"balance":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"balance"] doubleValue]]};
			[self.delegate gotStatsFromOmnichainWithData:statsDictionary];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"getwstats"];
		return;
	}
	
	methodSubString = connection.currentRequest.URL.query.length >= @"method=earningscalc".length ?
	[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, @"method=earningscalc".length)] : @"";
	// checks if said address belongs to a valid wallet
	if ([methodSubString isEqualToString:@"method=earningscalc"]) {
		NSError *error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		// check if json is valid
		if (!error) {
			// check if request is valid
			if ([[jsonObject valueForKey:@"error"] boolValue] == 1) {
				[self.delegate omnichainFailedWithWallet:self error:[jsonObject valueForKey:@"error_info"]];
				return;
			}
			NSDictionary *estimationDictionary = @{@"daily":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"daily"] doubleValue]],
											  @"weekly":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"weekly"] doubleValue]],
											  @"monthly":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"monthly"] doubleValue]],
											  @"yearly":[NSNumber numberWithDouble:[[[jsonObject valueForKey:@"response"] valueForKey:@"yearly"] doubleValue]]};
			[self.delegate gotCalculatedEarningsFromOmnichainWithHashrate:_tempHashrate difficulty:_tempDifficulty data:estimationDictionary];
		} else {
			[self.delegate omnichainFailedWithWallet:self error:@"API_CHANGED"];
			return;
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"earningscalc"];
		return;
	}
}

#pragma mark -

@end
