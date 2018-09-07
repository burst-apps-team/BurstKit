# BurstKit
Burstcoin Swift Development Framework

BurstKit simplifies integrating with the Burst API for iOS devices.  It provides wrappers for the [Burst API's](https://burstwiki.org/wiki/The_Burst_API) and implements Crypto utilities needed for key generation and signing.

## Using Burst API's in Swift

```swift
let service = BurstService(session: URLSession.shared)
service.getUnconfirmedTransactions(url: nil, account: account, apiCompletion: completion(
  onResult: { response in
    // BurstUnconfirmedTransactions
  },
  onError: { error in
    // Handle Error
  }
))
```

## Installing with Carthage

```ruby
github "aprock/BurstKit"
```
