//
//  BurstAccountPublicKeyResponse.swift
//  BurstKit
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public struct BurstPublicKey: Decodable {

  enum DataKeys: String, CodingKey {
    case publicKey
  }
  
  let publicKey: String

}
