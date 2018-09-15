//
//  BurstService.swift
//  BurstKit
//
//  Created by Andy Prock on 7/21/18.
//  Copyright © 2018 PoC-Consortium. All rights reserved.
//

import Foundation

public enum BurstError: Error, Equatable {
  case ApiError(String)
}

public struct BurstService {
  static let DEFAULT_BURST_URL = "https://wallet.burst.cryptoguru.org:8125/burst";

  private let session: URLSession
  private let endpoint: String

  init(session: URLSession = .shared, endpoint: String = DEFAULT_BURST_URL) {
    self.session = session
    self.endpoint = endpoint
  }

  /*
   * Method responsible for getting the unconfirmed transactions for the account.
   */
  public func getUnconfirmedTransactions(account: String, apiCompletion: @escaping ((BurstUnconfirmedTransactions?, Error?) -> Void)) {
    let queryDictionary = ["requestType": "getUnconfirmedTransactions", "account": account]

    let burstRequest = buildBurstRequest(queryDictionary: queryDictionary)
    session.dataTask(with: burstRequest, completion: completion(
      onResult: { response in
        let (transactions, err) = self.safeDecode(decodingType: BurstUnconfirmedTransactions.self, data: response.data);
        apiCompletion(transactions, err)
      },
      onError: { error in
        apiCompletion(nil, error)
      }
    )).resume()
  }

  /*
   * Method responsible for getting the latest 15 transactions.
   */
  public func getTransactions(account:String, apiCompletion: @escaping ((BurstTransactions?, Error?) -> Void)) {
    let queryDictionary = [
      "requestType": "getAccountTransactions",
      "firstIndex": "0",
      "lastIndex": "15",
      "account": account]

    let burstRequest = buildBurstRequest(queryDictionary: queryDictionary)
    session.dataTask(with: burstRequest, completion: completion(
      onResult: { response in
          let (transactions, err) = self.safeDecode(decodingType: BurstTransactions.self, data: response.data);
          apiCompletion(transactions, err)
      },
        onError: { error in
          apiCompletion(nil, error)
      }
    )).resume()
  }

  /*
   * Method responsible for getting a transaction.
   */
  public func getTransaction(transaction:String, apiCompletion: @escaping ((BurstTransaction?, Error?) -> Void)) {
    let queryDictionary = ["requestType": "getTransaction", "transaction": transaction]

    let burstRequest = buildBurstRequest(queryDictionary: queryDictionary)
    session.dataTask(with: burstRequest, completion: completion(
      onResult: { response in
        let (transaction, err) = self.safeDecode(decodingType: BurstTransaction.self, data: response.data);
        apiCompletion(transaction, err)
      },
      onError: { error in
        apiCompletion(nil, error)
      }
    )).resume()
  }

  /*
   * Method responsible for getting the current balance of an account.
   */
  public func getBalance(account:String, apiCompletion: @escaping ((BurstBalance?, Error?) -> Void)) {
    let queryDictionary = ["requestType": "getAccountBalance", "account": account]

    let burstRequest = buildBurstRequest(queryDictionary: queryDictionary)
    session.dataTask(with: burstRequest, completion: completion(
      onResult: { response in
        let (balance, err) = self.safeDecode(decodingType: BurstBalance.self, data: response.data);
        apiCompletion(balance, err)
      },
      onError: { error in
        apiCompletion(nil, error)
      }
    )).resume()
  }

  /*
   * Method responsible for getting the public key in the blockchain of an account.
   */
  public func getPublicKey(account:String, apiCompletion: @escaping ((BurstPublicKey?, Error?) -> Void)) {
    let queryDictionary = ["requestType": "getAccountPublicKey", "account": account]

    let burstRequest = buildBurstRequest(queryDictionary: queryDictionary)
    session.dataTask(with: burstRequest, completion: completion(
      onResult: { response in
        let (publicKey, err) = self.safeDecode(decodingType: BurstPublicKey.self, data: response.data);
        apiCompletion(publicKey, err)
      },
      onError: { error in
        apiCompletion(nil, error)
      }
    )).resume()
  }

  /*
   * Safely decodes burst api json responses, first checking for errors
   */
  private func safeDecode<T: Decodable>(decodingType: T.Type, data: Data) -> (T?, Error?) {
    do {
      let result = try JSONDecoder().decode(BurstApiError.self, from: data)
      return (nil, BurstError.ApiError(result.errorDescription))
    } catch {
      // ignoring error
    }

    do {
      let result = try JSONDecoder().decode(decodingType, from: data)
      return (result, nil)
    } catch {
      return (nil, error)
    }
  }

  /*
   * Builds a burst api GET request with query parameters
   */
  private func buildBurstRequest(queryDictionary: [String: String]) -> URLRequest {
    var components = URLComponents(string: endpoint)
    components?.queryItems = queryDictionary.map {
      URLQueryItem(name: $0, value: $1)
    }
  
    return URLRequest(url: components!.url!)
  }

}
