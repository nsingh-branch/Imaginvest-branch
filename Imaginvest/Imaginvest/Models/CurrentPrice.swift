//
//  CurrentPrice.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/23/21.
//

import Foundation

typealias CurrentPrice = [CurrentPriceElement]

struct CurrentPriceElement: Codable {
    let price: Double
}
