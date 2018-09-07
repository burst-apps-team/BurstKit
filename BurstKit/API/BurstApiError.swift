//
//  BurstError.swift
//  BurstKit
//
//  Created by Andy Prock on 9/6/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public struct BurstApiError: Decodable {

  enum DataKeys: String, CodingKey {
    case errorDescription
    case errorCode
  }

  let errorDescription: String
  let errorCode: Float

}
