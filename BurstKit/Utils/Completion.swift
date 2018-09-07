//
//  Completion.swift
//  BurstKit
//
//  Created by Andy Prock on 9/5/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

enum SplitError: Error {
  case NoResultFound
}

func completion<Result>(onResult: @escaping (Result) -> Void, onError: @escaping (Error) -> Void) -> ((Result?, Error?) -> Void) {
  return { (maybeResult, maybeError) in
    if let result = maybeResult {
      onResult(result)
    } else if let error = maybeError {
      onError(error)
    } else {
      onError(SplitError.NoResultFound)
    }
  }
}
