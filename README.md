# OMChainKit [![Build Status](https://travis-ci.org/ZaneH/OMChainKit.svg?branch=master)](https://travis-ci.org/ZaneH/OMChainKit)
An API wrapper for https://omnicha.in/api

## Delegates
> **`- (void)omnichainSucceededWithWallet:(OMChainWallet *)wallet method:(NSString *)method`**: Called whenever an API request succeeds. Use the method argument to see what the delegate is talking about.

-

> **`- (void)omnichainFailedWithWallet:(OMChainWallet *)wallet error:(NSString *)error`**: Called whenever an API fails for a multitude of reasons. See all the errors associated with their methods at http://www.omnicha.in/api
Use the error argument to see what the error was.

-

> **`- (void)signedMessageSuccessfullyWithAddress:(NSString *)address message:(NSString *)message signature:(NSString *)signature`**: Called whenever a message has been signed to an address successfully. Use the address, message, and signature arguments to get information on what was created.

-

> **`- (void)successfullyCreatedOmnicoinAddressWithAddress:(NSString *)address`**: Called whenever a new Omnicoin address was created. Use the address argument to see the address of the newly created address.

## Current Methods
### OMChainWallet
> **`- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password delegate:(id<OMChainDelegate>)delegate`**: Used to create a new `OMChainWallet` object. The delegate is a required argument because of how imporant delegates are to this wrapper. Username and password should both be passed in plain text.

-

> **`- (instancetype)init`**: Creates an empty wallet with all values initialized.

-

> **`- (void)setTimout:(NSUInteger)timeOut`**: Sets the timeout value for NSMutableURLRequest.

-

> **`- (void)getWalletInfo`**: Updates all the wallet info. ([wallet_getinfo](https://omnicha.in/api#wallet_getinfo-docs))

-

> **`- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword`**: Registers a new account with Omnicha.in using password confirmation. ([wallet_register](https://omnicha.in/api#wallet_register-docs))

-

> **`- (void)registerAccountWithUsername:(NSString *)username password:(NSString *)password`**: Registers a new account with Omnicha.in without using password confirmation. ([wallet_changepassword](https://omnicha.in/api#wallet_changepassword-docs))

-

> **`- (void)createAPIRequestWithMethod:(NSString *)method params:(NSDictionary *)params`**: Creates a custom API call with custom parameters. Helpful for calling API calls not yet implemented in the wrapper.

-

> **`- (void)changeEmailForAccountWithNewEmail:(NSString *)email`**:  ([wallet_changeemail](https://omnicha.in/api#wallet_changeemail-docs))

-

> **`- (void)changePasswordForAccountWithNewPassword:(NSString *)password confirmPassword:(NSString *)confirmPassword`**: Changes the password on the account using a confirmation password. ([wallet_changepassword](https://omnicha.in/api#wallet_changepassword-docs))

-

> **`- (void)changePasswordForAccountWithNewPassword:(NSString *)password`**: Changes the password on the account without using a confirmation password. ([wallet_changepassword](https://omnicha.in/api#wallet_changepassword-docs))

-

> **`- (void)signMessageWithAddress:(NSString *)address message:(NSString *)message`**: Signs a message to an address, check the delegate call for more details. ([wallet_signmessage](https://omnicha.in/api#wallet_signmessage-docs))

-

> **`- (void)importPrivateKeyWithKey:(NSString *)privateKey address:(NSString *)address`**: **DEPRECATED**. ([wallet_importkey](https://omnicha.in/api#wallet_importkey-docs))

-

> **`- (void)sendOmnicoinToAddress:(NSString *)address amount:(double)amount`**: Send Omnicoins to a specified address with a specified amount. Check the delegate call for more details. ([wallet_send](https://omnicha.in/api#wallet_send-docs))

-

> **`- (void)generateNewAddress`**: Creates a new address on Omnicha.in. Limited to 1/minute. Check delegate call for more details. ([wallet_genaddr](https://omnicha.in/api#wallet_genaddr-docs))
