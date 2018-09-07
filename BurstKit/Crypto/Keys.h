//
//  Keys.h
//  BurstKit
//
//  Created by Andy Prock on 7/15/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keys : NSObject

@property (nonatomic) NSData* publicKey;
@property (nonatomic) NSData* signPrivateKey;
@property (nonatomic) NSData* agreementPrivateKey;

- (instancetype)initWithPublicKey:(NSData*)publicKey
                   signPrivateKey:(NSData*)signPrivateKey
              agreementPrivateKey:(NSData*)agreementPrivateKey;

@end
