//
//  BurstBalance.swift
//  BurstKit
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public struct BurstBalance: Decodable {

  enum DataKeys: String, CodingKey {
    case unconfirmedBalanceNQT
    case guaranteedBalanceNQT
    case effectiveBalanceNXT
    case forgedBalanceNQT
    case balanceNQT
  }
  
  let unconfirmedBalanceNQT: String
  let guaranteedBalanceNQT: String
  let effectiveBalanceNXT: String
  let forgedBalanceNQT: String
  let balanceNQT: String

}
