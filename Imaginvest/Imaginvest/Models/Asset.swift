//
//  Asset.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//

import Foundation

struct Asset: Codable {
    let ticker: String
    let cost: Double
    let name: String
    let purchaseDate: Date?
    var price: Double?
    var percentGain: Double?
    
    var dictionary: [String: Any] {
        return ["ticker": ticker,
                "cost": cost,
                "name": name,
                "purchaseDate": purchaseDate
        ]
    }
    
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    init(ticker: String, cost: Double, name: String, purchaseDate: Date? = nil, price: Double? = nil, percentGain: Double? = nil) {
        self.ticker = ticker
        self.cost = cost
        self.name = name
        self.purchaseDate = purchaseDate
        self.price = price
        self.percentGain = percentGain
    }
}
