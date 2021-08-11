//
//  Networking.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//

import Foundation
import UIKit

class Networking {
    //https://cloud.iexapis.com/stable/stock/pltr/chart/date/20210616?chartLast=1&token=pk_5e373a2df52f40fcbdb05bab4c84bc2f Get price on past date
    //https://cloud.iexapis.com/stable/tops/last?symbols=SNAP&token=pk_5e373a2df52f40fcbdb05bab4c84bc2f Get current price
    
    func getOldPrice(ticker: String, on date: String, completion: @escaping (Double) -> Void) {
        let url = "https://cloud.iexapis.com/stable/stock/\(ticker)/chart/date/\(date)?chartLast=1&token=pk_5e373a2df52f40fcbdb05bab4c84bc2f"
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching price: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data {
                do {
                    let price = try JSONDecoder().decode(OldPrice.self, from: data)
                    print("The price of \(ticker.uppercased()) on \(date) was \(price.first?.average ?? 0.0001)")
                    completion(price.first?.average ?? 0.0001)
                                        
                } catch {
                    print("Error decoding OldPrice: \(error)")
                }
            }
        })
        task.resume()
    }
    
    func getCurrentPrice(ticker: String, completion: @escaping (Double) -> Void) {
        let url = "https://cloud.iexapis.com/stable/tops/last?symbols=\(ticker)&token=pk_5e373a2df52f40fcbdb05bab4c84bc2f"
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching price: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data {
                do {
                    let price = try JSONDecoder().decode(CurrentPrice.self, from: data)
                    completion(price.first?.price ?? 0.00)
                                        
                } catch {
                    print("Error decoding CurrentPrice: \(error)")
                }
                
            }
        })
        task.resume()
    }
    
    func getCompanyName(ticker: String, completion: @escaping (String) -> Void) {
        let url = "https://cloud.iexapis.com/stable/stock/\(ticker)/company?token=pk_5e373a2df52f40fcbdb05bab4c84bc2f"
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching company data: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data {
                do {
                    let company = try JSONDecoder().decode(Company.self, from: data)
                    completion(company.companyName)
                                        
                } catch {
                    print("Error decoding company data: \(error)")
                }
                
            }
        })
        task.resume()
    }
}
