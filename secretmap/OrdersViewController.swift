//
//  OrdersViewController.swift
//  secretmap
//
//  Created by Joe Anthony Peter Amanse on 2/21/18.
//  Copyright © 2018 Anton McConville. All rights reserved.
//

import UIKit

class OrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let cellReuseIdentifier = "cell"
    
    var userContracts: [Contract]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let themeColor = UIColor.init(red: 232.00/255.00, green: 139.00/255.00, blue: 123.00/255.00, alpha: 1)
        let statusBar = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        statusBar.backgroundColor = themeColor
        statusBar.tintColor = themeColor
        view.addSubview(statusBar)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userContracts!.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.userContracts!.reversed()[indexPath.row].id + " - " + self.userContracts!.reversed()[indexPath.row].state
        cell.textLabel?.textColor = UIColor.init(red: 215.00/255.00, green: 44.00/255.00, blue: 101.00/255.00, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transitionToContractView(payload: self.userContracts![self.userContracts!.count - 1 - indexPath.row])
    }
    
    private func transitionToContractView(payload: Contract) {
        let contractViewController = self.storyboard?.instantiateViewController(withIdentifier: "contractReceived") as? ContractViewController
        contractViewController?.payload = payload
        print(payload)
        contractViewController?.receivedFromQuantityView = false
        self.present(contractViewController!, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
