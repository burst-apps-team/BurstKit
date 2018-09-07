//
//  URLSession.swift
//  BurstKit
//
//  Created by Andy Prock on 9/5/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

struct Response {
  let data: Data
  let metadata: URLResponse?
}

extension URLSession {
  func dataTask(with url: URLRequest, completion: @escaping ((Response?, Error?) -> Void)) -> URLSessionDataTask {
    return dataTask(with: url, completionHandler: { (maybeData, maybeResponse, maybeError) in
      if let data = maybeData {
        completion(Response(data: data, metadata: maybeResponse), nil)
      } else if let error = maybeError {
        completion(nil, error)
      }
    })
  }
}
