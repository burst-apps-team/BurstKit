//
//  Keys.m
//  BurstKit
//
//  Created by Andy Prock on 7/15/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

#import "Keys.h"

@implementation Keys

- (instancetype)initWithPublicKey:(NSData*)publicKey
                   signPrivateKey:(NSData*)signPrivateKey
              agreementPrivateKey:(NSData*)agreementPrivateKey {
  self = [super init];
  if (self) {
    _publicKey =  [publicKey copy];
    _signPrivateKey = [signPrivateKey copy];
    _agreementPrivateKey = [agreementPrivateKey copy];
  }
  return self;
}

@end
