//
//  API.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import PromiseKit

typealias JSONResponse = [String: Any]

private let scheme = "https"
private let baseURLString = "timetableapi.ptv.vic.gov.au"

enum APIError: Error {
  case badURL
  case parser
  case server
  case malformedJson
}

protocol API {
  func tick(currency: String, instrument: String) -> Promise<JSONResponse>
  func tickerHistory(from: Int, to: Int, forTimeWindow timeWindow: TimeWindow, currency: String, instrument: String) -> Promise<JSONResponse>
}

extension API {
  func tick(currency: String, instrument: String) -> Promise<JSONResponse> {
    let url = URL(string: "https://api.btcmarkets.net/market/\(instrument)/\(currency)/tick")!
    let session = URLSession(configuration: .default)
    
    return Promise { fulfill, reject in
      let task = session.dataTask(with: url) { data, response, error in
        if let error = error {
          reject(error)
        }
        
        guard let data = data else {
          reject(APIError.server)
          return
        }
    
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? JSONResponse else {
          reject(APIError.malformedJson)
          return
        }
        
        fulfill(json)
      }
      
      task.resume()
    }
  }
  
  func tickerHistory(from: Int, to: Int, forTimeWindow timeWindow: TimeWindow, currency: String, instrument: String) -> Promise<JSONResponse> {
    let url = URL(string: "https://btcmarkets.net/data/market/BTCMarkets/\(instrument)/\(currency)/tickByTime?timeWindow=\(timeWindow.rawValue)&since=\(from)&_=\(to)")!
    let session = URLSession(configuration: .default)

    return Promise { fulfill, reject in
      let task = session.dataTask(with: url) { data, response, error in
        if let error = error {
          reject(error)
        }
        
        guard let data = data else {
          reject(APIError.server)
          return
        }
        
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? JSONResponse else {
          reject(APIError.malformedJson)
          return
        }
        
        fulfill(json)
      }
      
      task.resume()
    }
  }
}

class RestfulAPI: API {}
