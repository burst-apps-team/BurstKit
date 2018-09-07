//
//  BurstAddressTests.swift
//  BurstcoinTests
//
//  Created by Andy Prock on 5/30/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import XCTest
@testable import BurstKit

class BurstAddressTests: XCTestCase {
    
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testBurstAddressEncode() {
    XCTAssertEqual("1234567890123456789".burstAddressEncode(), "BURST-M2AP-YKYY-P84J-3JJA4")
  }
  
  func testBurstAddressDecode() {
    XCTAssertEqual("BURST-M2AP-YKYY-P84J-3JJA4".burstAddressDecode(), "1234567890123456789")
  }

  func testIsValidBurstAddress() {
    XCTAssertTrue("BURST-M2AP-YKYY-P84J-3JJA4".isValidBurstAddress())
    XCTAssertFalse("-BURST-M2AP-YKYY-P84J-3JJA4".isValidBurstAddress())
    XCTAssertFalse("BURST-M2AP-YKYY-A84J-3JJA4".isValidBurstAddress())
    XCTAssertFalse("BURST-M2IP-YKYY-P84J-3JJA4".isValidBurstAddress())
  }
  
  func testIsBurstAddress() {
    XCTAssertTrue("BURST-M2AP-YKYY-P84J-3JJA4".isBurstcoinAddress())
    XCTAssertFalse("-BURST-M2AP-YKYY-P84J-3JJA4".isBurstcoinAddress())
    XCTAssertFalse("BURST-M2AP-YKYY-A84J-3JJA4".isBurstcoinAddress())
  }

  func testBurstAddressSplit() {
    XCTAssertEqual("BURST-M2AP-YKYY-P84J-3JJA4".splitBurst(), ["M2AP", "YKYY", "P84J", "3JJA4"])
  }
  
  func testBurstAddressConstruct() {
    XCTAssertEqual(String(burst: ["M2AP", "YKYY", "P84J", "3JJA4"]), "BURST-M2AP-YKYY-P84J-3JJA4")
  }

}
