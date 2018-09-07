//
//  BurstUnconfirmedTransactionsTests.swift
//  BurstcoinTests
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation


import XCTest
@testable import BurstKit

class BurstUnconfirmedTransactionsTests: XCTestCase {

  func testDecoding() {
    let publicKey = "a61325eec9e83d7cac55544b8eca8ea8034559bafb5834b8a5d3b6d4efb85f12"

    let transactions = try! JSONDecoder().decode(BurstUnconfirmedTransactions.self, from: """
      {
        "unconfirmedTransactions": [
          {
            "senderPublicKey": "\(publicKey)",
            "signature": "5316c88b00f767d2bbe0cac07ae4f84b1fe75f002e24e9ce1c1a6b81d6821f09474a4db22db8461be85ac03f7c7df37fa007bd1aa72c34fc4be0e64b605bb2d6",
            "feeNQT": "100000000",
            "type": 1,
            "fullHash": "480ae3eba6a4e445c692eacae605bfaecd060e91005f96b09d57647d3c5fcf25",
            "version": 1,
            "ecBlockId": "3371057862366354193",
            "signatureHash": "d156bf1cdf9c8fce254a9ef3a7d47ed2f16a35ad94c8c625ec48a83fbda1b615",
            "attachment": {
              "name": "API-Examples2",
              "description": "",
              "version.AccountInfo": 1
            },
            "senderRS": "BURST-FRDJ-UPLH-MY9A-GUKQP",
            "subtype": 5,
            "amountNQT": "0",
            "sender": "16922903237994405232",
            "ecBlockHeight": 498894,
            "deadline": 1440,
            "transaction": "5036331320136108616",
            "timestamp": 120675576,
            "height": 498903
          },
          {
            "senderPublicKey": "\(publicKey)",
            "signature": "194bd83c8473d5bfef972e50efde4699db401d9097dcb68eaa898042d5022c0a1e64d551e20d6f49402d34f930317577f90152949485f8515d8b89e5bbbf45c0",
            "feeNQT": "100000000",
            "type": 0,
            "fullHash": "0c53db6986e2ba38119354158128e60f23a749fec0acf893ff3ca2de22176df0",
            "version": 1,
            "ecBlockId": "3371057862366354193",
            "signatureHash": "3b1b88980766b041165a55c622a6eea4b08bb628eab95e3016c19838fda6c112",
            "senderRS": "BURST-HKML-NRG6-VBRA-2F8PS",
            "subtype": 0,
            "amountNQT": "10013275142",
            "sender": "888561138747819634",
            "recipientRS": "BURST-WXWK-MD2A-KXJL-HR27T",
            "recipient": "18200197947533981585",
            "ecBlockHeight": 498894,
            "deadline": 1440,
            "transaction": "4087828678721622796",
            "timestamp": 120675589,
            "height": 498903
          },
      ],
      "requestProcessingTime": 1
    }
    """.data(using: .utf8)!)

    XCTAssertEqual(transactions.unconfirmedTransactions.count, 2)
    XCTAssertEqual(transactions.unconfirmedTransactions[0].senderPublicKey, publicKey)
  }

}
