//
//  BurstUnconfirmedTransactions.swift
//  BurstKit
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public struct BurstUnconfirmedTransactions: Decodable {

  enum DataKeys: String, CodingKey {
    case unconfirmedTransactions
  }

  let unconfirmedTransactions: [BurstTransaction]

}
