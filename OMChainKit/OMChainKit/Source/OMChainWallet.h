//
//  OMChainWallet.h
//  OMChainKit
//
//  Created by Zane Helton on 3/15/15.
//  Copyright (c) 2015 ZaneHelton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "OMChainAddress.h"
#import "OMChainTransaction.h"

@protocol OMChainDelegate;

@interface OMChainWallet : NSObject <NSURLConnectionDelegate>

#pragma mark - Properties

// User Info
/**
 *  The session token after a wallet is signed in
 */
@property (copy) NSString *sessionToken;
/**
 *  The email address assigned to the account (most often is blank)
 */
@property (copy) NSString *emailAddress;
/**
 *  The username of the current wallet user
 */
@property (copy) NSString *username;
/**
 *  The password used to verify an account (hashed with SHA512)
 */
@property (copy) NSString *passwordHash;


// Money Info
/**
 *  The balance of the wallet
 */
@property (assign) double balance;
/**
 *  The balance pending for the account
 */
@property (assign) double pendingBalance;
/**
 *  An array containing all the addresses for an account
 */
@property (nonatomic, strong) NSMutableArray *addresses;
/**
 *  A bool determining if the address is valid or not
 */
@property (assign) BOOL validAddress;


// Stats
/**
 *  Transactions that have been sent (1+ per transaction)
 */
@property (nonatomic) NSInteger transactionsOut;
/**
 *  Transactions that have been recieved (1+ per transaction)
 */
@property (nonatomic) NSInteger transactionsIn;
/**
 *  Total amount of OMC sent out
 */
@property (assign) double totalOut;
/**
 *  Total amount of OMC in
 */
@property (assign) double totalIn;
/**
 *  An array containing the transactions of the user
 */
@property (nonatomic, strong) NSMutableArray *transactions;
/**
 *  The conversion rate for 1 OMC -> USD
 */
@property (assign) double omcUSDValue;
/**
 *  Current version of the API
 */
@property (copy) NSString *version;


// Delegates
/**
 *  Delegate used to call errors, and successes
 */
@property (nonatomic, weak) id<OMChainDelegate> delegate;

#pragma mark -

#pragma mark - Initializers

/**
 *  Initializes a new wallet
 *
 *  @param username A string containing the username of the account
 *  @param password A string containing the plain text password of an account
 *
 *  @return A new wallet object
 */
- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password delegate:(id<OMChainDelegate>)delegate;

/**
 *  A method that returns a blank Omnicoin wallet
 *
 *  @return An empty wallet
 */
- (instancetype)init;

#pragma mark -

#pragma mark - Configuration Methods

- (void)setTimout:(NSUInteger)timeOut;

#pragma mark -

#pragma mark - API Interaction Method Declarations

/**
 *  Fills in the wallet properties
 */
- (void)getWalletInfo;

/**
 *  Registers a new account with Omnicha.in
 *
 *  @param username        The username to register the account under
 *  @param password        Password in plain text
 *  @param confirmPassword Password again in plain text (optional)
 */
- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword;

/**
 *  Registers a new account with Omnicha.in
 *
 *  @param username        The username to register the account under
 *  @param password        Password in plain text
 */
- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password;

/**
 *  Creates an API request with specified values
 *
 *  @param method    The Omnicha.in API method to call
 *  @param params An NSDictionary containing the keys and values to pass to the API
 */
- (void)createAPIRequestWithMethod:(NSString *)method params:(NSDictionary *)params;

/**
 *  Changes the users email address
 *
 *  @param email The new email address
 */
- (void)changeEmailForAccountWithNewEmail:(NSString *)email;

/**
 *  Changes the users password
 *
 *  @param password        Password in plain text
 *  @param confirmPassword Password again in plain text (optional)
 */
- (void)changePasswordForAccountWithNewPassword:(NSString *)password confirmPassword:(NSString *)confirmPassword;

/**
 *  Changes the users password
 *
 *  @param password Password in plain text
 */
- (void)changePasswordForAccountWithNewPassword:(NSString *)password;

/**
 *  Signs a message with the specified address
 *
 *  @param address A valid Omnicoin address
 *  @param message The message to sign
 */
- (void)signMessageWithAddress:(NSString *)address message:(NSString *)message;

/**
 *  Imports a private key into Omnicha.in
 *
 *  @param privateKey The private key you want to import
 */
- (void)importPrivateKeyWithKey:(NSString *)privateKey address:(NSString *)address __attribute__((deprecated));

/**
 *  Sends Omnicoin to an address
 *
 *  @param address Address to send Omnicoin to
 *  @param amount  The amount of Omnicoin to send to the address
 */
- (void)sendOmnicoinWithAddress:(NSString *)address amount:(double)amount;

/**
 *  Generates a new Omnicoin address
 */
- (void)generateNewAddress;

#pragma mark -

@end

@protocol OMChainDelegate <NSObject>

@required
/**
 *  Is called whenever the Omnicha.in API returns an error
 *
 *  @param wallet The wallet the method failed with
 *  @param error  The error code
 */
- (void)omnichainFailedWithWallet:(OMChainWallet *)wallet error:(NSString *)error;

/**
 *  Called whenever the OMChainWallet object is successfully created
 *
 *  @param wallet The wallet the method passed with
 *  @param method Method that succeeded
 */
- (void)omnichainSucceededWithWallet:(OMChainWallet *)wallet method:(NSString *)method;

@optional
/**
 *  Called whenever an address is successfully signed
 *
 *  @param address   Address that was signed
 *  @param message   Message for the address
 *  @param signature The signature that was returned
 */
- (void)signedMessageSuccessfullyWithAddress:(NSString *)address message:(NSString *)message signature:(NSString *)signature;

- (void)successfullyCreatedOmnicoinAddressWithAddress:(NSString *)address;

@end