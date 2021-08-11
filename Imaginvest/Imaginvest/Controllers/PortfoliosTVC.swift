//
//  PortfoliosTVC.swift
//  Imaginvest
//
//  Created by Nipun Singh on 6/22/21.
//

import UIKit

class PortfoliosTVC: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var portfolios = [Portfolio]()
    var selectedPort: Portfolio?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Portfolios"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPortfolio))
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getAllPortfolios()
    }
    
    //MARK: - Core Data Functions
    
    func getAllPortfolios() {
        do {
            portfolios = try context.fetch(Portfolio.fetchRequest())
            
            print("Got \(portfolios.count) total portfolios.")
         
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print("Error fetching portfolio")
        }
    }
    
    func createPortfolio(name: String) {
        
        let newPortfolio = Portfolio(context: context)
        newPortfolio.name = name
        newPortfolio.dateCreated = Date()
        newPortfolio.id = UUID()
        
        do {
            try context.save()
            print("Added portfolio: \(newPortfolio.name!)")
            getAllPortfolios()
            
        } catch {
            print("Error creating new portfolio")
        }
        
    }
    
    @objc func addPortfolio() {
        
        let alert = UIAlertController(title: "Create New Portfolio", message: "Enter a name for this portfolio", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Portfolio Name"
        }
        let submit = UIAlertAction(title: "Submit", style: .cancel) { [weak self] _ in
            let text = alert.textFields?.first
            
            self?.createPortfolio(name: text?.text ?? "")
            
        }
        
        alert.addAction(submit)
        
        present(alert, animated: true)
        
    }
    
    @objc func refresh(sender:AnyObject) {

        getAllPortfolios()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolios.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioCell
        
        cell.port = portfolios[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(portfolios[indexPath.row])
        selectedPort = portfolios[indexPath.row]
        performSegue(withIdentifier: "goToPortfolio", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            context.delete(portfolios[indexPath.row])
            portfolios.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do {
                try context.save()
                print("Deleted portfolio")
                getAllPortfolios()
                
            } catch {
                print("Error creating new portfolio")
            }
            
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPortfolio" {
            let vc = segue.destination as! AssetsTVC
            vc.portfolio = selectedPort
            vc.context = context
        }
    }
    

}
