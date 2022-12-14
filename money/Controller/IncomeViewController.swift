//
//  IncomeViewController.swift
//  money
//
//  Created by User on 28.11.2022.
//

import UIKit

class IncomeViewController: UIViewController, AccountPassingDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var amountField: UITextField!

    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var layout = SetupLayout()
    var alert = WarningAlert()
    var date = SetupDate()
    
    var primaryAccount: Account?
    var indexOfAccount: Int?
    var selectedCategory: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.setLayout(button: saveButton, view: saveView)
        layout.setLayout(button: accountButton, view: accountView)
        
        amountField.keyboardType = .decimalPad
        
        for (index, account) in accounts.enumerated() {
            if account.isMain == true {
                self.indexOfAccount = index
                self.primaryAccount = account
            }
        }
        
        accountNameLabel.text = "Account: \(primaryAccount!.name)"

        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryReusableCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IncomeAccounts" {
            let accVC = segue.destination as! SelectAccountsViewController
            accVC.delegate = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameField.resignFirstResponder()
        amountField.resignFirstResponder()
    }
    
    func sendAccount(account: Account, index: Int) {
        self.indexOfAccount = index
        self.primaryAccount = account
        self.accountNameLabel.text = "Account: \(primaryAccount!.name)"
    }
    
    @IBAction func accountButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "IncomeAccounts", sender: self)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let name = nameField.text
        let amount = amountField.text
        
        if name != "" {
            if amount != "" {
                if selectedCategory != nil {
                    
                    let rightAmount = amount!.replacingOccurrences(of: ",", with: ".")
                    
                    let newOper = Operation(title: name!, category: catOfIncomes[selectedCategory!], date: Date(), amount: Float(rightAmount)!, status: 1, account: primaryAccount!.name)
                    
                    date.setupDate(newOper: newOper)
                    
                    counter.calculate(operation: newOper, index: indexOfAccount!)
                    
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    present(alert.getWarningAlert(message: "Please, select a category!"), animated: true)
                }
            } else {
                present(alert.getWarningAlert(message: "Please, enter an amount!"), animated: true)
            }
        } else {
            present(alert.getWarningAlert(message: "Please, enter a name!"), animated: true)
        }
        
    }
    
}

extension IncomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategory = indexPath.row
        if self.nameField.text == "" {
            self.nameField.text = catOfIncomes[indexPath.row].title
        }
    }
}

extension IncomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catOfIncomes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = catOfIncomes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryReusableCell", for: indexPath) as! CategoryTableViewCell

        cell.categoryView.layer.cornerRadius = 8
        
        cell.iconView.backgroundColor = category.color
        cell.iconImage.image = UIImage(systemName: category.icon)
        cell.categoryLabel.text = category.name
        
        return cell
    }
}
