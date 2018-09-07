//
//  Crypto.h
//  BurstKit
//
//  Created by Andy Prock on 7/9/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Keys.h"

@interface Crypto : NSObject

+ (NSData*) getPublicKey:(NSString*) passPhrase;
+ (NSData*) getPrivateKey:(NSString*) passPhrase;
+ (Keys*)generateMasterKeys:(NSString*) passPhrase;

+ (NSData*) sign:(NSData*) data with:(NSString*) passPhrase;
+ (BOOL) verify:(NSData*)signature publicKey:(NSData*)pubKey data:(NSData*)data;

+ (NSData*) aesEncrypt:(NSData*) plainText privateKey:(NSData*)privateKey;
+ (NSData*) aesDecrypt:(NSData*) ivCipherData privateKey:(NSData*)privateKey;

+ (NSData*) encryptMessage:(NSData*) plainText myPrivateKey:(NSData*)privKey theirPublicKey:(NSData*)pubKey nonce:(NSData*)nonce;
+ (NSData*) decryptMessage:(NSData*) ivCiphertext myPrivateKey:(NSData*)privKey theirPublicKey:(NSData*)pubKey nonce:(NSData*)nonce;

+ (NSData*) sha256:(NSData*)data;

@end
