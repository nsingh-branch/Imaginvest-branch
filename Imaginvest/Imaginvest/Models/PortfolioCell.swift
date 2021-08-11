//
//  PortfolioCell.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/23/21.
//

import UIKit

class PortfolioCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var assetCountLabel: UILabel!
    @IBOutlet weak var returnView: UIView!
    @IBOutlet weak var returnLabel: UILabel!
    
    var port: Portfolio? {
        didSet {
            guard let portfolio = port else { return }
            
            nameLabel.text = portfolio.name
            
            returnView.layer.cornerRadius = 4
            returnView.layer.masksToBounds = true
            
            if let allAssets = portfolio.assets {
                do {
                    
                    //Decode assets and calculate the total 
                    var assets = try JSONDecoder().decode([Asset].self, from: allAssets)
                    assetCountLabel.text = "\((assets.count)) Assets"
                    
                    for i in 0..<assets.count {
                        let ticker = assets[i].ticker
                        let cost = assets[i].cost
                        Networking().getCurrentPrice(ticker: ticker) { (currentPrice) in
                            let percentGain = ((currentPrice - cost) /  cost) * 100

                            assets[i].price = currentPrice
                            assets[i].percentGain = percentGain
                            
                            if (i + 1) == assets.count {
                                var totalCost = 0.0
                                var totalPrice = 0.0
                                for asset in assets {
                                    totalCost += asset.cost
                                    totalPrice += asset.price ?? 0.0
                                }
                                
                                let totalPortReturn = ((totalPrice - totalCost) / totalCost) * 100
                                var totalPortReturnString = "\(String(format: "%.2f", totalPortReturn))%"

                                if totalPortReturn > 0 {
                                    totalPortReturnString.insert("+", at: totalPortReturnString.startIndex)
                                }
                                
                                DispatchQueue.main.async {
                                    self.returnLabel.text = totalPortReturnString
                                 
                                    self.returnView.backgroundColor = totalPortReturn < 0 ? .systemRed : .systemGreen
                                }
                            }
                        }
                    }

                } catch {
                    print("Error decoding assets count: \(error)")
                    assetCountLabel.text = "0 Assets"
                    returnLabel.text = "-"
                    returnView.backgroundColor = .systemGray2
                }
            } else {
                assetCountLabel.text = "0 Assets"
                returnLabel.text = "-"
                returnView.backgroundColor = .systemGray2

            }
            
            
        }
    }
}
