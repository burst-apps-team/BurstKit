//
//  CryptoTests.swift
//  BurstcoinTests
//
//  Created by Andy Prock on 5/30/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import XCTest
@testable import BurstKit

class CryptoTests: XCTestCase {

  var crypto: Crypto!
  
  var passphrase: String!
  var publicKey: String!
  var privateKey: String!
  var pin: Int!
  var id: String!
  var address: String!
  var message: String!
  var signatureHex: String!
  
  override func setUp() {
    super.setUp()
    
    passphrase = "ach wie gut dass niemand weiss dass ich Rumpelstilzchen heiss"
    publicKey = "6b223e427b2d44ef8fe2dcb64845d7d9790045167202f1849facef10398bd529"
    privateKey = "34306951463caaca27fd6f0696ae5747e89a6af55d7b53c1dfac08d02266fdb438c0962fe6ccb06d26a948e92b43fc87bb702a7ab29d22c8a672e0fc6e570e43"
    pin = 777666
    id = "6779331401231193177"
    address = "BURST-LP4T-ZQSJ-9XMS-77A7W"
    message = "hello"
    signatureHex = "343e2233f1ea3df493e49abb5ebc90ff14df02ab1e85bf0897a698c28330a60729f1f4eeb08f49c2c179bd0b51bbca661b8195787703530586c286a8297ca07e"
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()

    passphrase = nil
    publicKey = nil
    privateKey = nil
    pin = 0
    id = nil
    address = nil
  }
  
  func testGenerateMasterKeys() {
    let pub: String = Crypto.getPublicKey(passphrase).map { String(format: "%02hhx", $0) }.joined()
    XCTAssertEqual(pub, publicKey)
  }

  func testSigning() {
    let payload: Data = message.data(using: .ascii)!
    let signature: Data = Crypto.sign(payload, with: passphrase)
    XCTAssertEqual(signature.map { String(format: "%02hhx", $0) }.joined(), signatureHex)
    XCTAssertTrue(Crypto.verify(signature, publicKey: Crypto.getPublicKey(passphrase), data: payload))
  }
  
  func testEncryption() {
    let payload: Data = message.data(using: .ascii)!
    let publicKey: Data = Crypto.getPublicKey(passphrase)
    let privateKey: Data = Crypto.getPrivateKey(passphrase)

    let bytes = [UInt32](repeating: 0, count: 32).map { _ in arc4random() }
    let nonce = Data(bytes: bytes, count: 32)

    let encrypted: Data = Crypto.encryptMessage(payload, myPrivateKey: privateKey, theirPublicKey: publicKey, nonce: nonce)
    let decrypted: Data = Crypto.decryptMessage(encrypted, myPrivateKey: privateKey, theirPublicKey: publicKey, nonce: nonce)
    XCTAssertEqual(decrypted, payload)
  }
}
