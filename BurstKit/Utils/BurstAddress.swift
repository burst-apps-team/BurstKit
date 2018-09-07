//
//  BurstAddress.swift
//  BurstKit
//
//  Created by Andy Prock on 5/28/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

let initialCodeword = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
let gexp = [1, 2, 4, 8, 16, 5, 10, 20, 13, 26, 17, 7, 14, 28, 29, 31, 27, 19, 3, 6, 12, 24, 21, 15, 30, 25, 23, 11, 22, 9, 18, 1]
let glog = [0, 0, 1, 18, 2, 5, 19, 11, 3, 29, 6, 27, 20, 8, 12, 23, 4, 10, 30, 17, 7, 22, 28, 26, 21, 25, 9, 16, 13, 14, 24, 15]
let cwmap = [3, 2, 1, 0, 7, 6, 5, 4, 13, 14, 15, 16, 12, 8, 9, 10, 11]
let alphabet = Array("23456789ABCDEFGHJKLMNPQRSTUVWXYZ")
let base32Length = 13
let zero = UInt16(48) // utf-16 "0"
let burstPrefix = "BURST-"

public extension String {
  private func ginv(a: Int) -> Int {
    return gexp[31 - glog[a]]
  }

  private func gmult(a: Int, b: Int) -> Int {
    if (a == 0 || b == 0) {
      return 0
    }

    let idx = (glog[a] + glog[b]) % 31;
    return gexp[idx];
  }

  func burstAddressEncode() -> String {
    var plainString10 = [UInt16]()
    var codeword = initialCodeword
    var pos = 0
    var length = count

    for a in utf16 {
      plainString10.append(a - zero)
    }

    repeat { // base 10 to base 32 conversion
      var digit32 = UInt16(0)
      var newLength = 0

      for i in 0..<length {
        digit32 = UInt16(digit32 * 10) + plainString10[i]
        if (digit32 >= 32) {
          plainString10[newLength] = digit32 >> 5
          digit32 &= 31
          newLength += 1
        } else if (newLength > 0) {
          plainString10[newLength] = 0
          newLength += 1
        }
      }

      length = newLength
      codeword[pos] = Int(digit32)
      pos += 1
    } while (length > 0)

    var p = [0, 0, 0, 0]

    for i in stride(from: base32Length - 1, to: -1, by: -1) {
      let fb = codeword[i] ^ p[3]

      p[3] = p[2] ^ gmult(a:30, b:fb)
      p[2] = p[1] ^ gmult(a:6, b:fb)
      p[1] = p[0] ^ gmult(a:9, b:fb)
      p[0] = gmult(a:17, b:fb)
    }

    codeword[13] = p[0]
    codeword[14] = p[1]
    codeword[15] = p[2]
    codeword[16] = p[3]

    var out = burstPrefix

    for i in 0..<17 {
      out.append(alphabet[codeword[cwmap[i]]])

      if ((i & 3) == 3 && i < 13) {
        out.append("-")
      }
    }

    return out
  }

  /*
   * Decode a BURST-XXXX-XXXX-XXXX-XXXXX into a numeric id
   */
  func burstAddressDecode() -> String? {
    if !isValidBurstAddress() {
      return nil
    }

    guard let range = range(of: burstPrefix, options: .anchored) else {
      return nil
    }

    // remove Burst prefix
    let address = self[range.upperBound...]

    var codeword = initialCodeword
    var codewordLength = 0

    for i in 0..<address.count {
      let idx = address.index(address.startIndex, offsetBy: i)
      guard let pos = alphabet.index(of: address[idx]) else {
        continue
      }

      if (pos > alphabet.count) {
        continue
      }

      if (codewordLength > 16) {
        return nil
      }

      let codeworkIndex = cwmap[codewordLength]
      codeword[codeworkIndex] = pos
      codewordLength += 1
    }

    var length = base32Length
    var cypherString32 = Array(repeating: 0, count: length)

    for i in 0..<length {
      cypherString32[i] = codeword[length - i - 1]
    }

    var out = ""

    repeat { // base 32 to base 10 conversion
      var newLength = 0
      var digit10 = 0

      for i in 0..<length {
        digit10 = digit10 * 32 + cypherString32[i]

        if (digit10 >= 10) {
          cypherString32[newLength] = Int(floor(Double(digit10) / 10.0))
          digit10 %= 10
          newLength += 1
        } else if (newLength > 0) {
          cypherString32[newLength] = 0
          newLength += 1
        }
      }
      length = newLength
      out += String(digit10)
    } while (length > 0)

    return String(out.reversed())
  }

  /*
   * Check for valid Burst address (format: BURST-XXXX-XXXX-XXXX-XXXXX, XXXX-XXXX-XXXX-XXXXX)
   */
  func isValidBurstAddress() -> Bool {
    guard let range = range(of: burstPrefix, options: .anchored) else {
      return false
    }

    let address = self[range.upperBound...]
    var codeword = initialCodeword
    var codewordLength = 0

    for i in 0..<address.count {
      let idx = address.index(address.startIndex, offsetBy: i)
      guard let pos = alphabet.index(of: address[idx]) else {
        continue
      }

      if (pos > alphabet.count) {
        continue
      }

      if (codewordLength > 16) {
        return false
      }

      let codeworkIndex = cwmap[codewordLength]
      codeword[codeworkIndex] = pos
      codewordLength += 1
    }

    if (codewordLength != 17) {
      return false;
    }

    var sum = 0;

    for i in 1..<5 {
      var t = 0;

      for j in 0..<31 {
        if (j > 12 && j < 27) {
          continue
        }

        var pos = j
        if (j > 26) {
          pos -= 14
        }

        t ^= gmult(a: codeword[pos], b: gexp[(i * j) % 31])
      }

      sum |= t
    }

    return (sum == 0)
  }

  /*
   * Split the Burst address string into an array of 4 parts
   */
  func splitBurst() -> [String] {
    var parts = [String]()
    parts = components(separatedBy: "-")
    if (parts.count != 5) {
      return [String]()
    }

    parts.remove(at: 0)
    return parts
  }

  /*
   * Construct a Burst address from a string array
   */
  public init(burst: [String]) {
    self.init("BURST-" + burst[0] + "-" + burst[1] + "-" + burst[2] + "-" + burst[3])
  }

  /*
   * Validation Check. Quick validation of Burst addresses included
   * https://burstwiki.org/wiki/RS_Address_Format
   */
  func isBurstcoinAddress() -> Bool {
    guard let _ = range(of: "^BURST(-((?![OI])[A-Z2-9]){4}){3}-((?![OI])[A-Z2-9]){5}", options: .regularExpression) else {
      return false
    }

    return isValidBurstAddress()
  }
}
