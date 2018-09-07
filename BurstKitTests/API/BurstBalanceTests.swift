//
//  BurstBalanceTests.swift
//  BurstcoinTests
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

import XCTest
@testable import BurstKit

class BurstBalanceTests: XCTestCase {

  func testDecoding() {
    let balance = "100000000000"
    let decoded = try! JSONDecoder().decode(BurstBalance.self, from: """
      {
        "unconfirmedBalanceNQT": "\(balance)",
        "guaranteedBalanceNQT": "\(balance)",
        "effectiveBalanceNXT": "\(balance)",
        "forgedBalanceNQT": "0",
        "balanceNQT": "\(balance)",
        "requestProcessingTime": 0
      }
    """.data(using: .utf8)!)

    XCTAssertEqual(decoded.unconfirmedBalanceNQT, balance)
    XCTAssertEqual(decoded.guaranteedBalanceNQT, balance)
    XCTAssertEqual(decoded.effectiveBalanceNXT, balance)
    XCTAssertEqual(decoded.balanceNQT, balance)
  }

}
