//
//  ThreadSafeAccess.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 6/8/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

class ThreadSafeDictionary<Key, Value> where Key: Hashable {
  private var dictionary: [Key: Value] = [:]
  private let accessQueue = DispatchQueue(label: UUID.init().uuidString)

  subscript(index: Key) -> Value? {
    get {
      return accessQueue.sync {
        return self.dictionary[index]
      }
    }
    set {
      accessQueue.async {
        self.dictionary[index] = newValue
      }
    }
  }
}
