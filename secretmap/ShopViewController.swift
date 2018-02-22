//
//  ShopViewController.swift
//  secretmap
//
//  Created by Joe Anthony Peter Amanse on 2/15/18.
//  Copyright © 2018 Anton McConville. All rights reserved.
//

import UIKit

struct Product: Codable {
    let sellerid: String
    let productid: String
    let name: String
    let count: Int
    let price: Int
}

struct ResultOfBlockchain: Codable {
    let message: String
    let result: String
}

class ShopViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var ordersButton: UIBarButtonItem!
    @IBOutlet weak var fitcoinsBalance: UILabel!
    
    var currentUser: BlockchainUser?
    var receivedProductList: [Product]?
    var userState: GetStateFinalResult?
    
    @IBAction func unwindToShop(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data = userState
        if let destinationViewController = segue.destination as? OrdersViewController {
            destinationViewController.userState = data
        }
    }
    
    // Go to Quantity View
    @objc func tapDetected(gesture: UITapGestureRecognizer) {
        let resultViewController = self.storyboard?.instantiateViewController(withIdentifier: "quantity") as! QuantityViewController
        resultViewController.payload = receivedProductList![gesture.view!.tag]
        self.present(resultViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ordersButton.isEnabled = false
        self.getStateOfUser(currentUser!.userId)
        
        guard let url = URL(string: "http://148.100.98.53:3000/api/execute") else { return }
        let parameters: [String:Any]
        let request = NSMutableURLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //{"userId":"766f2d71-a286-441b-afdd-11824c2ee226","fcn":"getProductsForSale","args":[]}
        let args: [String] = []
        parameters = ["type":"query", "queue":"user_queue","params":["userId":currentUser!.userId, "fcn":"getProductsForSale","args":args]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let showProducts = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized, let status = json["status"], let resultId = json["resultId"] {
                        NSLog(status as! String)
                        NSLog(resultId as! String) // Use this one to get blockchain payload - should contain userId
                        
                        // Start pinging backend with resultId
                        self.requestResults(resultId: resultId as! String, attemptNumber: 0)
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        showProducts.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let themeColor = UIColor.init(red: 232.00/255.00, green: 139.00/255.00, blue: 123.00/255.00, alpha: 1)
        let statusBar = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        statusBar.backgroundColor = themeColor
        statusBar.tintColor = themeColor
        view.addSubview(statusBar)
        
        currentUser = BookletController().loadUser()
        // Do any additional setup after loading the view.
    }
    
    func newProductView(productId: String, index: Int) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "fitcoin@2x.png"))
        imageView.frame = CGRect(x: 0, y: index*100, width: 100, height: 100)
        imageView.contentMode = .scaleToFill
        imageView.tag = index
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDetected)))
        return imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestResults(resultId: String, attemptNumber: Int) {
        // recursive function limited to 60 attempts
        if attemptNumber < 60 {
            guard let url = URL(string: "http://148.100.98.53:3000/api/results/" + resultId) else { return }
            
            let session = URLSession.shared
            let resultsFromBlockchain = session.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        // data is
                        // {"status":"done","result":"{\"message\":\"success\",\"result\":\"[{\\\"sellerid\\\":\\\"f7fe46c2-589e-4b7d-99f8-39be0d97557f\\\",\\\"productid\\\":\\\"stickers-1234\\\",\\\"name\\\":\\\"Stickers\\\",\\\"count\\\":1000,\\\"price\\\":5},{\\\"sellerid\\\":\\\"f7fe46c2-589e-4b7d-99f8-39be0d97557f\\\",\\\"productid\\\":\\\"shirt-1234\\\",\\\"name\\\":\\\"Shirt\\\",\\\"count\\\":1000,\\\"price\\\":50}]\"}"}
                        
                        let backendResult = try JSONDecoder().decode(BackendResult.self, from: data)
                        
                        if backendResult.status == "done" {
                            
                            let resultOfBlockchain = try JSONDecoder().decode(ResultOfBlockchain.self, from: backendResult.result!.data(using: .utf8)!)
                            print(resultOfBlockchain)
                            
                            let productList = try JSONDecoder().decode([Product].self, from: resultOfBlockchain.result.data(using: .utf8)!)
                            self.receivedProductList = productList
                            DispatchQueue.main.async {
                                var index = 0;
                                for product in productList {
                                    print(product)
                                    print(index)
                                    let productImageView = self.newProductView(productId: product.productid, index: index)
                                    productImageView.alpha = 0
                                    self.scrollView.addSubview(productImageView)
                                    UIView.animate(withDuration: 0.5, animations: {productImageView.alpha = 1.0})
                                    index = index + 1;
                                }
                            }
                        }
                        else {
                            let when = DispatchTime.now() + 1
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                self.requestResults(resultId: resultId, attemptNumber: attemptNumber+1)
                            }
                        }
                    }  catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            resultsFromBlockchain.resume()
        }
        else {
            NSLog("Attempted 60 times to enroll... No results")
        }
    }
    
    // This should get user profile from userId
    // The request is queued
    private func getStateOfUser(_ userId: String) {
        guard let url = URL(string: "http://148.100.98.53:3000/api/execute") else { return }
        let parameters: [String:Any]
        let request = NSMutableURLRequest(url: url)
        
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let args: [String] = [userId]
        parameters = ["type":"query", "queue":"user_queue", "params":["userId": userId,"fcn": "getState", "args":args]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let getStateOfUser = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized, let status = json["status"], let resultId = json["resultId"] {
                        NSLog(status as! String)
                        NSLog(resultId as! String) // Use this one to get blockchain payload
                        
                        // Start checking if our queued request is finished.
                        self.requestUserState(resultId: resultId as! String, attemptNumber: 0)
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        getStateOfUser.resume()
    }
    
    private func requestUserState(resultId: String, attemptNumber: Int) {
        // recursive function limited to 60 attempts
        if attemptNumber < 60 {
            guard let url = URL(string: "http://148.100.98.53:3000/api/results/" + resultId) else { return }
            
            let session = URLSession.shared
            let resultsFromBlockchain = session.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        // data is
                        // {"status":"done","result":"{\"message\":\"success\",\"result\":\"{\\\"user\\\":\\\"4226e3af-5ae3-49bc-870c-886af9ec53a3\\\"}\"}"}
                        // Convert the data to JSON
                        let backendResult = try JSONDecoder().decode(BackendResult.self, from: data)
                        if backendResult.status == "done" {
                            print(backendResult.result!)
                            let resultOfBlockchain = try JSONDecoder().decode(ResultOfBlockchain.self, from: backendResult.result!.data(using: .utf8)!)
                            let finalResultOfGetState = try JSONDecoder().decode(GetStateFinalResult.self, from: resultOfBlockchain.result.data(using: .utf8)!)
                            self.userState = finalResultOfGetState
                            DispatchQueue.main.async {
                                self.ordersButton.isEnabled = true
                                self.fitcoinsBalance.text = String(describing: finalResultOfGetState.fitcoinsBalance)
                            }
                        }
                        else {
                            let when = DispatchTime.now() + 0.5 // 3 seconds from now
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                self.requestUserState(resultId: resultId, attemptNumber: attemptNumber+1)
                            }
                        }
                    }  catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            resultsFromBlockchain.resume()
        }
        else {
            NSLog("Attempted 60 times to enroll... No results")
        }
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
