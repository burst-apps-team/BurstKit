//
//  BurstServiceTests.swift
//  BurstKitTests
//
//  Created by Andy Prock on 9/6/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

import XCTest
@testable import BurstKit

class BurstServiceTests: XCTestCase {
  var account: String!

  override func setUp() {
    super.setUp()
    account = "BURST-GBFG-HVQ4-8AMM-GPCWR"
  }

  func testErrorHandling() {
    let session = URLSessionMock()
    let service = BurstService(session: session)

    let description = "Incorrect request"
    session.data = """
      {"errorDescription":"\(description)","errorCode":1}
    """.data(using: .utf8)!

    service.getUnconfirmedTransactions(account: account, apiCompletion: completion(
      onResult: { response in
        XCTAssert(false)
      },
      onError: { error in
        XCTAssertEqual(error as! BurstError, BurstError.ApiError(description))
      }
    ))
  }

  func testBalanceRequest() {
    let session = URLSessionMock()
    let service = BurstService(session: session)

    let balance = "100000000000"
    session.data = """
      {
      "unconfirmedBalanceNQT": "\(balance)",
      "guaranteedBalanceNQT": "\(balance)",
      "effectiveBalanceNXT": "\(balance)",
      "forgedBalanceNQT": "0",
      "balanceNQT": "\(balance)",
      "requestProcessingTime": 0
      }
      """.data(using: .utf8)!

    service.getBalance(account: account, apiCompletion: completion(
      onResult: { response in
        XCTAssertEqual(response.unconfirmedBalanceNQT, balance)
      },
      onError: { error in
        XCTAssert(false)
      }
    ))
  }

}
