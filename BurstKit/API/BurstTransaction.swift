//
//  Transaction.swift
//  BurstKit
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

// TODO : add attachment support

/*
 * Transaction class
 *
 * The Transaction class is a mapping for a transaction on the Burst blockchain
 */
public struct BurstTransaction {

  enum DataKeys: String, CodingKey {
    case recipientAddress = "recipientRS"
    case senderAddress = "senderRS"
    case id = "transaction"

    case amountNQT
    case block
    case blockTimestamp
    case confirmations
    case deadline
    case ecBlockId
    case feeNQT
    case fullHash
    case height
    case recipientId
    case senderPublicKey
    case signature
    case signatureHash
    case subtype
    case timestamp
    case type
    case version
  }

  let id: String
  let amountNQT: String
  let block: String?
  let blockTimestamp: Double?
  let confirmations: Double?
  let deadline: Double
  let ecBlockId: String
  let feeNQT: String
  let fullHash: String
  let height: Double
  let recipientId: String?
  let recipientAddress: String?
  let senderPublicKey: String
  let senderAddress: String
  let signature: String
  let signatureHash: String
  let subtype: Double
  let timestamp: Double
  let type: Double
  let version: Double

}

extension BurstTransaction: Decodable {

  public init(from decoder: Decoder) throws {
    let data = try decoder.container(keyedBy: DataKeys.self)

    id = try data.decode(String.self, forKey: .id)
    amountNQT = try data.decode(String.self, forKey: .amountNQT)
    deadline = try data.decode(Double.self, forKey: .deadline)
    ecBlockId = try data.decode(String.self, forKey: .ecBlockId)
    feeNQT = try data.decode(String.self, forKey: .feeNQT)
    fullHash = try data.decode(String.self, forKey: .fullHash)
    height = try data.decode(Double.self, forKey: .height)
    senderPublicKey = try data.decode(String.self, forKey: .senderPublicKey)
    senderAddress = try data.decode(String.self, forKey: .senderAddress)
    signature = try data.decode(String.self, forKey: .signature)
    signatureHash = try data.decode(String.self, forKey: .signatureHash)
    subtype = try data.decode(Double.self, forKey: .subtype)
    timestamp = try data.decode(Double.self, forKey: .timestamp)
    type = try data.decode(Double.self, forKey: .type)
    version = try data.decode(Double.self, forKey: .version)

    block = try data.decodeIfPresent(String.self, forKey: .block)
    blockTimestamp = try data.decodeIfPresent(Double.self, forKey: .blockTimestamp)
    confirmations = try data.decodeIfPresent(Double.self, forKey: .confirmations)
    recipientId = try data.decodeIfPresent(String.self, forKey: .recipientId)
    recipientAddress = try data.decodeIfPresent(String.self, forKey: .recipientAddress)
  }

}
