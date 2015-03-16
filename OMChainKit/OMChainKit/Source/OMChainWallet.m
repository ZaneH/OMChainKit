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
	
	NSMutableURLRequest *callMethodRequest = [[NSMutableURLRequest alloc]
											  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://omnicha.in/api?method=%@%@", method, requestString]]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:_timeOutInterval];
	[callMethodRequest setHTTPMethod:@"GET"];
	__unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:callMethodRequest delegate:self];
}

#pragma mark -

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// sets session token & checks login
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 19)] isEqualToString:@"method=wallet_login"]) {
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
	}
	
	// sets transactions out, total out, transactions in, total in, balance, pending balance, transactions, addresses, & omcUSDValue
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 21)] isEqualToString:@"method=wallet_getinfo"]) {
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
	}
	
	// creates a user on Omnicha.in
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 22)] isEqualToString:@"method=wallet_register"]) {
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
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_register"];
	}
	
	// changes users email address
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 26)] isEqualToString:@"method=wallet_changeemail"]) {
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
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_changeemail"];
	}
	
	// changes the users password
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 28)] isEqualToString:@"method=wallet_changepassword"]) {
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
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_changepassword"];
	}
	
	// signs a message to an address (I have no idea what this is tbh, but it was in the API and I needed to add it)
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 25)] isEqualToString:@"method=wallet_signmessage"]) {
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
		}
		[self.delegate signedMessageSuccessfullyWithAddress:_tempAddress message:_tempMessage signature:[[jsonObject valueForKey:@"response"] valueForKey:@"signature"]];
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_signmessage"];
	}
	
	// imports a previously generated address into Omnicha.in
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 23)] isEqualToString:@"method=wallet_importkey"]) {
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
		}
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_importkey"];
	}
	
	// generates a new address on Omnicha.in
	if ([[connection.currentRequest.URL.query substringWithRange:NSMakeRange(0, 21)] isEqualToString:@"method=wallet_genaddr"]) {
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
		}
		[self.delegate successfullyCreatedOmnicoinAddressWithAddress:[[jsonObject valueForKey:@"response"] valueForKey:@"address"]];
		[self.delegate omnichainSucceededWithWallet:self method:@"wallet_genaddr"];
	}
}

#pragma mark -

@end
