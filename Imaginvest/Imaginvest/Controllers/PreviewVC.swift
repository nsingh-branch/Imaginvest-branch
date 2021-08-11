//
//  PreviewVC.swift
//  Imaginvest
//
//  Created by Nipun Singh on 8/10/21.
//

import UIKit
import CoreData

class PreviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var api = Networking()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var linkData: [String: AnyObject]?
    
    var assets = [Asset]()
    var totalPortReturnString = ""
    var stats: Stats?
    
    @IBOutlet weak var previewNavBar: UINavigationBar!
    @IBOutlet weak var previewTableView: UITableView!
    
    @IBAction func addPortButtonPressed(_ sender: Any) {
            //Format and add this portfolio to coredata
            addPortfolio()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getPrices()
        
    }
    
    func setupUI() {
        previewNavBar.prefersLargeTitles = true
        previewNavBar.tintColor = .systemGreen
        previewNavBar.topItem?.title = linkData?["name"] as? String ?? "????"
        previewNavBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissPort))
                
        previewTableView.dataSource = self
        previewTableView.delegate = self
    }
    
    @objc func dismissPort() {
        dismiss(animated: true, completion: nil)
    }
    
    func addPortfolio() {

        let newPortfolio = Portfolio(context: context)
        newPortfolio.name = linkData?["name"] as? String ?? ""
        newPortfolio.dateCreated = linkData?["purchaseDate"] as? Date ?? Date()
        newPortfolio.id = UUID()
        let jsonData = try! JSONEncoder().encode(assets)
        newPortfolio.assets = jsonData
        
        do {
            try context.save()
            print("Added portfolio: \(newPortfolio.name!)")
            dismiss(animated: true, completion: nil)
            
        } catch {
            print("Error creating new portfolio")
        }
    }
    
    // MARK: Data setup
    
    func getPrices() {
        let assetDictArray = linkData!["assets"] as? [Dictionary<String, AnyObject>] ?? []
        for i in 0..<assetDictArray.count {
            let dict = assetDictArray[i]
            let ticker = dict["ticker"] as? String ?? ""
            let cost = dict["cost"] as? Double ?? 0
            let name = dict["name"] as? String ?? ""
            let purchaseDate = dict["purchaseDate"] as? Date ?? Date()
            
            api.getCurrentPrice(ticker: ticker) { currentPrice in
                let percentGain = ((currentPrice - cost) /  cost) * 100
               
                let asset = Asset(ticker: ticker, cost: cost, name: name, purchaseDate: purchaseDate, price: currentPrice, percentGain: percentGain)
                self.assets.append(asset)
                print(asset)
                
                DispatchQueue.main.async {
                    self.previewTableView.reloadData()
                }
                
                if (i + 1) == assetDictArray.count {
                    print("Added all assets, calculating stats now")
                    self.getStats()
                }
            }
        }
    }
    
    func getStats() {
        var totalCost = 0.0
        var totalPrice = 0.0
        var totalPercentage = 0.0
     
        for asset in assets {
            totalCost += asset.cost
            totalPrice += asset.price ?? 0.0
            totalPercentage +=  asset.percentGain ?? 0.0
        }
        
        let totalPortReturn = ((totalPrice - totalCost) / totalCost) * 100
        totalPortReturnString = "\(String(format: "%.2f", totalPortReturn))%"
        print("Total cost is $\(totalCost) and total price is $\(totalPrice).")
        print("Total port return is: \(String(format: "%.2f", totalPortReturn))%.")
        
        if totalPortReturn > 0 {
            totalPortReturnString.insert("+", at: totalPortReturnString.startIndex)
        }
        
        let bestAsset = assets.max { $0.percentGain ?? 0.0 < $1.percentGain ?? 0.0 }
        let worstAsset = assets.min { $0.percentGain ?? 0.0 < $1.percentGain ?? 0.0 }
        
        stats = Stats(totalReturnString: totalPortReturnString, totalCost: totalCost, totalPrice: totalPrice, totalPercentage: totalPercentage, bestAsset: bestAsset ?? assets[0], worstAsset: worstAsset ?? assets[0])
                
        DispatchQueue.main.async {
            self.previewNavBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: self.totalPortReturnString, style: .plain, target: self, action: #selector(self.showStats))
        }
    }
    
    @objc func showStats() {
        let cost = String(format: "%.2f", (stats?.totalCost ?? 0.0) as Double)
        let price = String(format: "%.2f", (stats?.totalPrice ?? 0.0) as Double)
        let percent = String(format: "%.2f", (stats?.totalPercentage ?? 0.0) as Double)
        let bestAssetString = "\(stats?.bestAsset.ticker ?? "?") (\(String(format: "%.2f", (stats?.bestAsset.percentGain ?? 0.0) as Double))%)"
        let worstAssetString = "\(stats?.worstAsset.ticker ?? "?") (\(String(format: "%.2f", (stats?.worstAsset.percentGain ?? 0.0) as Double))%)"

        
        let alert = UIAlertController(title: "Stats", message: "Total Return: \(stats?.totalReturnString ?? "+0.00%")\nTotal Assets: \(assets.count)\nBest Asset: \(bestAssetString)\nWorst Asset: \(worstAssetString)\n\nTotal Cost: $\(cost)\nTotal Price: $\(price)\nSum of returns: \(percent)%", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    
    // MARK: Tableview Setup
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath) as! AssetCell

        cell.asset = assets[indexPath.row]

        return cell
    }
    
}
