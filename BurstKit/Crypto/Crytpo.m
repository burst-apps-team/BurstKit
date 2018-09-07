//
//  Crytpo.m
//  BurstKit
//
//  Created by Andy Prock on 7/9/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

#import "Crypto.h"

#define ECCKeyLength 32
#define ECCSignatureLength 64

/** curve25519_i64 **/
extern void keygen25519(uint8_t* P, uint8_t* s, uint8_t* k);
extern int sign25519(uint8_t* v, const uint8_t* h, const uint8_t* x, const uint8_t* s);
extern void verify25519(uint8_t* Y, const uint8_t* v, const uint8_t* h, const uint8_t* P);
extern void curve25519(uint8_t* Z, const uint8_t* k, const uint8_t* P);

@implementation Crypto

const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
const NSUInteger kAlgorithmKeySize = kCCKeySizeAES128;
const NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;

+ (NSData*) getPublicKey: (NSString*) passPhrase {
  uint8_t publicKey[ECCKeyLength] = {0};
  uint8_t hash[ECCKeyLength] = {0};

  const char *s = [passPhrase cStringUsingEncoding:NSASCIIStringEncoding];
  NSData* data = [NSData dataWithBytes:s length:strlen(s)];

  CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
  keygen25519(publicKey, nil, hash);

  return [NSData dataWithBytes:publicKey length:ECCKeyLength];
}

+ (NSData*) getPrivateKey: (NSString*) passPhrase {
  uint8_t privateKey[ECCKeyLength] = {0};

  const char *s = [passPhrase cStringUsingEncoding:NSASCIIStringEncoding];
  NSData* data = [NSData dataWithBytes:s length:strlen(s)];

  CC_SHA256(data.bytes, (CC_LONG)data.length, privateKey);
  privateKey[31] &= 0x7F;
  privateKey[31] |= 0x40;
  privateKey[ 0] &= 0xF8;

  return [NSData dataWithBytes:privateKey length:ECCKeyLength];
}

+ (NSData*) getSignPrivateKey: (NSString*) passPhrase {
  uint8_t publicKey[ECCKeyLength] = {0};
  uint8_t signPrivateKey[ECCKeyLength] = {0};
  uint8_t hash[ECCKeyLength] = {0};

  const char *s = [passPhrase cStringUsingEncoding:NSASCIIStringEncoding];
  NSData* data = [NSData dataWithBytes:s length:strlen(s)];

  CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
  keygen25519(publicKey, signPrivateKey, hash);

  return [NSData dataWithBytes:signPrivateKey length:ECCKeyLength];
}

+ (Keys*)generateMasterKeys:(NSString*) passPhrase {
  uint8_t publicKey[ECCKeyLength] = {0};
  uint8_t signPrivateKey[ECCKeyLength] = {0};
  uint8_t agrementPrivateKey[ECCKeyLength] = {0};

  const char *s = [passPhrase cStringUsingEncoding:NSASCIIStringEncoding];
  NSData* data = [NSData dataWithBytes:s length:strlen(s)];

  CC_SHA256(data.bytes, (CC_LONG)data.length, agrementPrivateKey);
  keygen25519(publicKey, signPrivateKey, agrementPrivateKey);

  return [[Keys alloc] initWithPublicKey:[NSData dataWithBytes:publicKey length:ECCKeyLength]
                          signPrivateKey:[NSData dataWithBytes:signPrivateKey length:ECCKeyLength]
                     agreementPrivateKey:[NSData dataWithBytes:agrementPrivateKey length:ECCKeyLength]];
}

/* deterministic EC-KCDSA
 *
 *    s is the private key for signing
 *    P is the corresponding public key
 *    Z is the context data (signer public key or certificate, etc)
 *
 * signing:
 *
 *    m = hash(Z, message)
 *    x = hash(m, s)
 *    keygen25519(Y, NULL, x);
 *    r = hash(Y);
 *    h = m XOR r
 *    sign25519(v, h, x, s);
 *
 *    output (v,r) as the signature
 */
+ (NSData*) sign: (NSData*) data with: (NSString*) passPhrase {
  uint8_t P[ECCKeyLength] = {0};
  uint8_t s[ECCKeyLength] = {0};

  uint8_t k[ECCKeyLength] = {0};
  const char *str = [passPhrase cStringUsingEncoding:NSASCIIStringEncoding];
  NSData* passBytes = [NSData dataWithBytes:str length:strlen(str)];

  CC_SHA256(passBytes.bytes, (CC_LONG)passBytes.length, k);
  keygen25519(P, s, k);

  uint8_t m[ECCKeyLength] = {0};
  CC_SHA256(data.bytes, (CC_LONG)data.length, m);

  uint8_t x[ECCKeyLength] = {0};
  CC_SHA256_CTX ctx;
  CC_SHA256_Init(&ctx);
  CC_SHA256_Update(&ctx, m, ECCKeyLength);
  CC_SHA256_Update(&ctx, s, ECCKeyLength);
  CC_SHA256_Final(x, &ctx);

  uint8_t Y[ECCKeyLength] = {0};
  keygen25519(Y, nil, x);

  uint8_t h[ECCKeyLength] = {0};
  CC_SHA256_Init(&ctx);
  CC_SHA256_Update(&ctx, m, ECCKeyLength);
  CC_SHA256_Update(&ctx, Y, ECCKeyLength);
  CC_SHA256_Final(h, &ctx);

  uint8_t v[ECCKeyLength] = {0};
  sign25519(v, h, x, s);

  uint8_t signature[ECCSignatureLength] = {0};
  memcpy(signature, v, ECCKeyLength);
  memcpy(signature + ECCKeyLength, h, ECCKeyLength);

  return [NSData dataWithBytes: signature length: ECCSignatureLength];
}

/**
 * verification:
 *
 *    m = hash(Z, message);
 *    h = m XOR r
 *    verify25519(Y, v, h, P)
 *
 *    confirm  r == hash(Y)
 */
+ (BOOL) verify:(NSData*)signature publicKey:(NSData*)pubKey data:(NSData*)data {
  uint8_t v[ECCKeyLength] = {0};
  uint8_t h[ECCKeyLength] = {0};

  [signature getBytes:v length:32];
  [signature getBytes:h range:NSMakeRange(32, 32)];

  uint8_t Y[ECCKeyLength] = {0};
  verify25519(Y, v, h, pubKey.bytes);

  uint8_t m[ECCKeyLength] = {0};
  CC_SHA256(data.bytes, (CC_LONG)data.length, m);

  uint8_t h2[ECCKeyLength] = {0};
  CC_SHA256_CTX ctx;
  CC_SHA256_Init(&ctx);
  CC_SHA256_Update(&ctx, m, ECCKeyLength);
  CC_SHA256_Update(&ctx, Y, ECCKeyLength);
  CC_SHA256_Final(h2, &ctx);

  return 0 == memcmp(h, h2, ECCKeyLength);
}

+ (NSData*) getSharedSecret:(NSData*)myPrivateKey theirPublicKey:(NSData*)theirPublicKey {
  uint8_t sharedSecret[ECCKeyLength] = {0};
  curve25519(sharedSecret, myPrivateKey.bytes, theirPublicKey.bytes);
  return [NSData dataWithBytes:sharedSecret length:ECCKeyLength];
}

+ (NSData*) aesEncrypt: (NSData*) plainText privateKey:(NSData*)privateKey {
  NSMutableData* cipherData = [NSMutableData dataWithLength:plainText.length + kAlgorithmBlockSize];

  uint8_t iv[16] = {0};
  if (0 != SecRandomCopyBytes(kSecRandomDefault, 16, iv)) {
    return nil;
  }

  size_t outLength = 0;
  CCCryptorStatus result = CCCrypt(kCCEncrypt, // operation
                                   kAlgorithm, // Algorithm
                                   kCCOptionPKCS7Padding, // options
                                   privateKey.bytes, // key
                                   privateKey.length, // keylength
                                   iv,// iv
                                   plainText.bytes, // dataIn
                                   plainText.length, // dataInLength,
                                   cipherData.mutableBytes, // dataOut
                                   cipherData.length, // dataOutAvailable
                                   &outLength); // dataOutMoved
  if (result == kCCSuccess) {
    [cipherData replaceBytesInRange:NSMakeRange(0, 0) withBytes:(const void *)iv length:16];
    cipherData.length = outLength + 16;
  } else {
    return nil;
  }

  return cipherData;
}

+ (NSData*) aesDecrypt: (NSData*) ivCipherData privateKey:(NSData*)privateKey {
  uint8_t iv[16] = {0};
  [ivCipherData getBytes:iv range:NSMakeRange(0, 16)];

  unsigned long cipherDataLength = ivCipherData.length - 16;
  uint8_t* cipherData = malloc(cipherDataLength);
  [ivCipherData getBytes:cipherData range:NSMakeRange(16, cipherDataLength)];

  NSMutableData* plainData = [NSMutableData dataWithLength:cipherDataLength];

  size_t outLength = 0;
  CCCryptorStatus result = CCCrypt(kCCDecrypt, // operation
                                   kAlgorithm, // Algorithm
                                   kCCOptionPKCS7Padding, // options
                                   privateKey.bytes, // key
                                   privateKey.length, // keylength
                                   iv,// iv
                                   cipherData, // dataIn
                                   cipherDataLength, // dataInLength,
                                   plainData.mutableBytes, // dataOut
                                   plainData.length, // dataOutAvailable
                                   &outLength); // dataOutMoved

  if (result == kCCSuccess) {
    plainData.length = outLength;
  } else {
    return nil;
  }

  return plainData;
}

+ (NSData*) encryptMessage: (NSData*) plainText myPrivateKey:(NSData*)privKey theirPublicKey:(NSData*)pubKey nonce:(NSData*)nonce {
  uint8_t dhSharedSecret[ECCKeyLength] = {0};
  curve25519(dhSharedSecret, privKey.bytes, pubKey.bytes);

  const uint8_t* nonceBytes = nonce.bytes;
  for (int i = 0; i < 32; i++) {
    dhSharedSecret[i] ^= nonceBytes[i];
  }

  uint8_t key[ECCKeyLength] = {0};
  CC_SHA256(dhSharedSecret, ECCKeyLength, key);

  uint8_t iv[16] = {0};
  if (0 != SecRandomCopyBytes(kSecRandomDefault, 16, iv)) {
    return nil;
  }

  NSMutableData* cipherData = [NSMutableData dataWithLength:plainText.length + kAlgorithmBlockSize];

  size_t outLength = 0;
  CCCryptorStatus result = CCCrypt(kCCEncrypt, // operation
                                   kAlgorithm, // Algorithm
                                   kCCOptionPKCS7Padding, // options
                                   key, // key
                                   ECCKeyLength, // keylength
                                   iv,// iv
                                   plainText.bytes, // dataIn
                                   plainText.length, // dataInLength,
                                   cipherData.mutableBytes, // dataOut
                                   cipherData.length, // dataOutAvailable
                                   &outLength); // dataOutMoved

  if (result == kCCSuccess) {
    [cipherData replaceBytesInRange:NSMakeRange(0, 0) withBytes:(const void *)iv length:16];
    cipherData.length = outLength + 16;
  } else {
    return nil;
  }

  return cipherData;
}

+ (NSData*) decryptMessage: (NSData*) ivCiphertext myPrivateKey:(NSData*)privKey theirPublicKey:(NSData*)pubKey nonce:(NSData*)nonce {
  uint8_t iv[16] = {0};
  [ivCiphertext getBytes:iv range:NSMakeRange(0, 16)];

  unsigned long cipherTextLength = ivCiphertext.length - 16;
  uint8_t* cipherText = malloc(cipherTextLength);
  [ivCiphertext getBytes:cipherText range:NSMakeRange(16, cipherTextLength)];

  uint8_t dhSharedSecret[ECCKeyLength] = {0};
  curve25519(dhSharedSecret, privKey.bytes, pubKey.bytes);

  const uint8_t* nonceBytes = nonce.bytes;
  for (int i = 0; i < 32; i++) {
    dhSharedSecret[i] ^= nonceBytes[i];
  }

  uint8_t key[ECCKeyLength] = {0};
  CC_SHA256(dhSharedSecret, ECCKeyLength, key);

  NSMutableData* plainData = [NSMutableData dataWithLength:cipherTextLength];

  size_t outLength = 0;
  CCCryptorStatus result = CCCrypt(kCCDecrypt, // operation
                                   kAlgorithm, // Algorithm
                                   kCCOptionPKCS7Padding, // options
                                   key, // key
                                   ECCKeyLength, // keylength
                                   iv,// iv
                                   cipherText, // dataIn
                                   cipherTextLength, // dataInLength,
                                   plainData.mutableBytes, // dataOut
                                   plainData.length, // dataOutAvailable
                                   &outLength); // dataOutMoved

  if (result == kCCSuccess) {
    plainData.length = outLength;
  } else {
    return nil;
  }

  return plainData;
}

+ (NSData*) sha256:(NSData*)data {
  uint8_t hash[CC_SHA256_DIGEST_LENGTH] = {0};
  CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
  return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

@end
