//
//  URLSessionDataTaskMock.swift
//  BurstKitTests
//
//  Created by Andy Prock on 9/6/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

class URLSessionDataTaskMock: URLSessionDataTask {
  private let closure: () -> Void

  init(closure: @escaping () -> Void) {
    self.closure = closure
  }

  // We override the 'resume' method and simply call our closure
  // instead of actually resuming any task.
  override func resume() {
    closure()
  }
}
