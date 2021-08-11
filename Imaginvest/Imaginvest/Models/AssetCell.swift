//
//  AssetCell.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/23/21.
//

import UIKit

class AssetCell: UITableViewCell {

    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var tickerPriceLabel: UILabel!
    @IBOutlet weak var boughtLabel: UILabel!
    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var returnView: UIView!
    
    var asset: Asset? {
        didSet {
            guard let assetItem = asset else { return }
            
            companyLabel.text = assetItem.name
            tickerPriceLabel.text = "\(assetItem.ticker)  $\(String(format: "%.2f", assetItem.price ?? 0.00))"
            returnLabel.text = "\(String(format: "%.2f", assetItem.percentGain ?? 0.00))%"
            
            if assetItem.purchaseDate != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                let dateString = formatter.string(from: assetItem.purchaseDate!)
                boughtLabel.text = "\(dateString) at $\(String(format: "%.2f", assetItem.cost))"
            } else {
                boughtLabel.text = "Bought at $\(String(format: "%.2f", assetItem.cost))"
            }
            returnView.layer.cornerRadius = 4
            returnView.layer.masksToBounds = true
            
            if assetItem.percentGain ?? 0 < 0 {
                returnView.backgroundColor = .systemRed
            } else {
                returnView.backgroundColor = .systemGreen
            }
            
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
