//
//  CryptoStoreSpec.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 3/17/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import Quick
import Nimble
import RxSwift
@testable import BTC_Companion

private class MockDataStream: CryptoDataStream {

  var callback: CryptoDataStream.OnCryptoUpdated!

  func startStreaming() {}
  func stopStreaming() {}
  func setOnCryptoUpdated(callback: @escaping (Currency, Coin) -> Void) {
    self.callback = callback
  }

}

class CryptoStoreSpec: QuickSpec {
  private func onCryptoUpdate(currency: Currency, coin: Coin) {
  }

  let disposeBag = DisposeBag()

  override func spec() {
    describe("init") {
      it("should contain a notifier for every currency except AUD") {
        let dataStream = MockDataStream()
        let store = CryptoStore(dataStream: dataStream)

        for currency in Currency.allExceptAud {
          expect(store.notifier(forCurrency: currency)).notTo(beNil())
        }
      }
    }

    describe("update") {
      let dataStream: MockDataStream = MockDataStream()
      var store: CryptoStore!

      beforeEach {
        store = CryptoStore(dataStream: dataStream)
      }

      context("data has changed") {
        it("should receive an update when the data stream sends new data") {
          var coin = Coin(currency: .btc)
          coin.lastPrice = 3000

          dataStream.callback(.btc, coin)

          store.notifier(forCurrency: .btc)
            .price
            .subscribe(onNext: { (price) in
              expect(price) == 3000
            }).disposed(by: self.disposeBag)
        }
      }

      context("data has not changed") {
        it("should not receive an update when the data stream sends the same value twice") {
          let dataStream = MockDataStream()
          let store = CryptoStore(dataStream: dataStream)
          var updateCount = 0

          store.notifier(forCurrency: .btc)
            .price
            .subscribe(onNext: { (price) in
              updateCount += 1
            }).disposed(by: self.disposeBag)

          var coin = Coin(currency: .btc)
          coin.lastPrice = 3000

          var anotherCoin = Coin(currency: .btc)
          anotherCoin.lastPrice = 3000

          dataStream.callback(.btc, coin)
          dataStream.callback(.btc, anotherCoin)

          expect(updateCount).toEventually(equal(2))
        }
      }
    }
  }
}
