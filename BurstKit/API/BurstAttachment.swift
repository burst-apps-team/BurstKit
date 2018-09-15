//
//  BurstAttachment.swift
//  BurstKit
//
//  Created by Andy Prock on 9/14/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public struct Message: Decodable {

  enum DataKeys: String, CodingKey {
    case messageIsText
    case message
  }

  let messageIsText: Bool
  let message: String

}

public struct EncryptedMessage: Decodable {

  enum DataKeys: String, CodingKey {
    case data
    case nonce
    case isText
  }

  let isText: Bool
  let nonce: String
  let data: String

}

enum Attachment: Decodable {

  case message(Message), encryptedMessage(EncryptedMessage)

  func get() -> Any {
    switch self {
    case .message(let message):
      return message
    case .encryptedMessage(let encryptedMessage):
      return encryptedMessage
    }
  }

  init(from decoder: Decoder) throws {
    if let message = try? decoder.singleValueContainer().decode(Message.self) {
      self = .message(message)
      return
    }

    if let encryptedMessage = try? decoder.singleValueContainer().decode(EncryptedMessage.self) {
      self = .encryptedMessage(encryptedMessage)
      return
    }

    throw Attachement.missingValue
  }

  enum Attachement:Error {
    case missingValue
  }

}
