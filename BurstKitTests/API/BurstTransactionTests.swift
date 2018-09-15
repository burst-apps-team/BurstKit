//
//  BurstTransactionTests.swift
//  BurstcoinTests
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

import XCTest
@testable import BurstKit

class BurstTransactionTests: XCTestCase {

  func testDecoding() {
    let publicKey = "a61325eec9e83d7cac55544b8eca8ea8034559bafb5834b8a5d3b6d4efb85f12"
    let message = "This is a sendMessage API example"

    let transaction = try! JSONDecoder().decode(BurstTransaction.self, from: """
      {
        "senderPublicKey": "\(publicKey)",
        "signature": "dc2503584a48e30ac62d62848f58461e0e9ff55070008743c24f380c24a9ef05525c70b5d40962566f3f4de2018277ba7956eb09d0aec84219784de7f3b76f6a",
        "feeNQT": "735000",
        "requestProcessingTime": 0,
        "type": 1,
        "confirmations": 7,
        "fullHash": "0f37d045bc7d4f2bd85cb565a5c4e575464ac387b986f80fb8c31635cf03923e",
        "version": 1,
        "ecBlockId": "1212249281481197658",
        "signatureHash": "2bcbafeab7a0bae40337fe34adea84110b1f770a33841c95f3fe9e19dde41bae",
        "attachment": {
          "version.Message": 1,
          "messageIsText": true,
          "message": "\(message)"
        },
        "senderRS": "BURST-FRDJ-UPLH-MY9A-GUKQP",
        "subtype": 0,
        "amountNQT": "0",
        "sender": "16922903237994405232",
        "recipientRS": "BURST-L6FM-89WK-VK8P-FCRBB",
        "recipient": "15323192282528158131",
        "ecBlockHeight": 502787,
        "block": "2298247278137763160",
        "blockTimestamp": 121620850,
        "deadline": 24,
        "transaction": "3120851314369640207",
        "timestamp": 121620814,
        "height": 502797
      }
    """.data(using: .utf8)!)

    XCTAssertEqual(transaction.height, 502797)
    XCTAssertEqual(transaction.senderPublicKey, publicKey)
    XCTAssertEqual((transaction.attachment!.get() as! Message).message, message)
  }

}
