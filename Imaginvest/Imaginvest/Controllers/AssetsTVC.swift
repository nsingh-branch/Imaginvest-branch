//
//  AssetsTVC.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//

import UIKit
import CoreData
import Branch

class AssetsTVC: UITableViewController {
    
    let branch: Branch = Branch.getInstance()

    var context: NSManagedObjectContext?
    var portfolio: Portfolio?
    
    var assets = [Asset]()
    var api = Networking()
    var totalPortReturnString = ""
    var stats: Stats?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = portfolio?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(enterAsset))
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)

        
        getAssets()
    }
    
    func getAssets() {
        if let allAssets = portfolio?.assets {
            do {
                assets = try JSONDecoder().decode([Asset].self, from: allAssets) //TODO: Fix this
                
                getCurrentPrices()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Error: \(error)")
            }
            
        }
    }
    
    func createAsset(ticker: String, date: Date, cost: Double) {
        print("Trying to add asset \(ticker)")
        api.getCompanyName(ticker: ticker) { (companyName) in
            if cost < 0 {
//                let textFieldToDateFormatter = DateFormatter()
//                textFieldToDateFormatter.dateFormat = "MM' 'dd' 'yyyy"
//                let realDate = textFieldToDateFormatter.date(from: date)!
            
                let purchaseDateString = self.convertDate(date)
                
                self.api.getOldPrice(ticker: ticker, on: purchaseDateString) { (oldCost) in
                    
                    let newAsset = Asset(ticker: ticker.uppercased(), cost: oldCost, name: companyName, purchaseDate: date)
                    
                    self.assets.append(newAsset)
                    self.addAssetToPort()
                    
                }
                
            } else { //No date provided
                let newAsset = Asset(ticker: ticker.uppercased(), cost: cost, name: companyName)
                self.assets.append(newAsset)
                self.addAssetToPort()
                
            }
        }
     
    }
    
    func addAssetToPort() {
        let jsonData = try! JSONEncoder().encode(assets)
        portfolio?.assets = jsonData
        
        do {
            try context?.save()
            print("Added \(assets.last?.ticker.uppercased() ?? "TICKER") to the port")
            getAssets()
            
        } catch {
            print("Error adding asset: \(error)")
        }
    }
    
    @objc func enterAsset() {
        
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = .current
        myDatePicker.preferredDatePickerStyle = .compact
        myDatePicker.datePickerMode = .date
        myDatePicker.maximumDate = Date()
        myDatePicker.frame = CGRect(x: 72.5, y: 115, width: 140, height: 30)
        

        let alert = UIAlertController(title: "Add new asset", message: "Enter this asset's name and date purchased or cost\n\nEnter Date Purchased\n\n", preferredStyle: .alert)
        alert.view.addSubview(myDatePicker)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Asset Ticker"
        }

//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter Date Purchased (MM DD YYYY)"
//        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Cost (Optional)"
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            let ticker = alert.textFields?[0]
            let cost = alert.textFields?[1]
            
            if ticker?.text != "" {
                self?.createAsset(ticker: ticker?.text ?? "", date: myDatePicker.date, cost: Double(cost?.text ?? "-1") ?? -1)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(submit)
        alert.addAction(cancel)
        
        present(alert, animated: true)
        
    }
    
    func getCurrentPrices() {
        for i in 0..<assets.count {
            //Get each assets cost and price and calculate the return percentage
            let ticker = assets[i].ticker
            let cost = assets[i].cost
            api.getCurrentPrice(ticker: ticker) { (currentPrice) in
                let percentGain = ((currentPrice - cost) /  cost) * 100
                
                self.assets[i].price = currentPrice
                self.assets[i].percentGain = percentGain
                
                print("Asset #\(i + 1): \(self.assets[i])")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                if !self.assets.isEmpty && (i + 1) == self.assets.count {
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
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(enterAsset))
        let returns = UIBarButtonItem(title: totalPortReturnString, style: .plain, target: self, action: #selector(showStats))
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(self.sharePortfolio))
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItems = [add, share, returns]
        }
    }
    // MARK: Nav Bar Button Functions
    
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
    
    @objc func sharePortfolio() {
        let portUO = BranchUniversalObject.init(canonicalIdentifier: "portfolioShare")
        portUO.title = portfolio?.name
        portUO.contentDescription = "My Imaginvest Portfolio"
        portUO.imageUrl = "https://i.dlpng.com/static/png/6803271_preview.png"
        portUO.publiclyIndex = true
        portUO.locallyIndex = true
        portUO.contentMetadata.customMetadata = createPortDict()
        
        let lp: BranchLinkProperties = BranchLinkProperties()

        let message = "Check out this Imaginvest portfolio!"
        portUO.showShareSheet(with: lp, andShareText: message, from: self) { (activityType, completed) in
            print(activityType ?? "")
        }
        
    }
    
    func createPortDict() -> NSMutableDictionary {
        var assetsAsDicts: [NSDictionary] = []
        
        for asset in assets {
            assetsAsDicts.append(asset.nsDictionary)
        }
        
        return ["name": portfolio?.name ?? "My Port",
                "dateCreated": portfolio?.dateCreated ?? Date(),
                "id": portfolio?.id?.uuidString,
                "assets": assetsAsDicts
        ]
    }
    
    func convertDate(_ date: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "YYYYMMdd"
        return formatter1.string(from: date)
    }
    
    @objc func refresh(sender:AnyObject) {
        getAssets()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assetCell", for: indexPath) as! AssetCell
        
        cell.asset = assets[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            assets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let jsonData = try! JSONEncoder().encode(assets)
            portfolio?.assets = jsonData
            
            do {
                try context?.save()
                print("Deleted an asset from the port")
                getAssets()
                
            } catch {
                print("Error adding asset: \(error)")
            }
            
        }
    }
}
