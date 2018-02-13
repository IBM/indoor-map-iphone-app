//
//  SecondViewController.swift
//  secretmap
//
//  Created by Anton McConville on 2017-12-14.
//  Copyright © 2017 Anton McConville. All rights reserved.
//

import UIKit
import HealthKit
import CoreMotion

class DataViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate
    
    var pedometer = CMPedometer()
    
    public var startDate: Date = Date()
    
    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var fitcoinsLabel: UILabel!
    
    var currentUser: BlockchainUser?
    
    let FITCOIN_STEPS_CONVERSION: Int = 100
    
    var totalStepsConvertedToFitcoin: Int?
    var fitcoinsBalanceFromBlockchain: Int?
    
    var sendingInProgress: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        currentUser = BookletController().loadUser()
        if currentUser != nil {
            
            // Debugging alert
//            let alert = UIAlertController(title: "DEBUG: (already enrolled)", message: currentUser?.userId, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//
            let userId: String = currentUser!.userId
            userIdLabel?.text = userId
            
            self.getStateOfUser(userId)
        }
        else {
            
            // Debugging alert
//            let alert = UIAlertController(title: "DEBUG: (not yet enrolled)", message: "refresh the page later", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            userIdLabel?.text = "Enrolling in progress. Refresh the page at a later time"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStepData()
        self.liveUpdateStepData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let healthStore = HKHealthStore()
    
    func getStepData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var currentPerson:Person
        
        var people: [Person] = []
        
        do {
            people = try context.fetch(Person.fetchRequest())
            
            if( people.count > 0 ){
                currentPerson = people[0]
                
                self.startDate = currentPerson.startdate!
                
                pedometer.queryPedometerData(from: self.startDate, to: Date()) {
                    [weak self] pedometerData, error in
                    if let error = error {
                        //                        self?.on(error: error)
                    } else if let pedometerData = pedometerData {
                        DispatchQueue.main.async {
                            self?.stepsCountLabel.text = String(describing: pedometerData.numberOfSteps)
                            let distanceInKilometers: Double = (pedometerData.distance?.doubleValue)! / 1000.00
                            self?.distanceLabel.text = String(describing: distanceInKilometers)
                        }
                    }
                }
            }
        }catch{}
    }
    
    func liveUpdateStepData(){
        pedometer.startUpdates(from: self.startDate, withHandler: { (pedometerData, error) in
            if let pedometerData = pedometerData{
                DispatchQueue.main.async {
                    self.stepsCountLabel.text = String(describing: pedometerData.numberOfSteps)
                    let distanceInKilometers: Double = (pedometerData.distance?.doubleValue)! / 1000.00
                    self.distanceLabel.text = String(describing: distanceInKilometers)
                }
                
                // If nothing is sending yet
                if self.totalStepsConvertedToFitcoin != nil && self.sendingInProgress == false {
                    let difference: Int = pedometerData.numberOfSteps.intValue - self.totalStepsConvertedToFitcoin!
                    print(difference)
                    
                    // Only send when there is enough fitcoins to convert
                    if difference > self.FITCOIN_STEPS_CONVERSION {
                        
                        // Sending fitcoins sequence here
                        self.sendingInProgress = true
                        
                        
                        let userId: String? = self.currentUser!.userId
                        
                        // Send to fitchain network
                        self.sendStepsToFitchain(userId: userId, pedometerData: pedometerData)
                    }
                }
            } else {
                print("steps are not available")
            }
        })
    }
    
    private func sendStepsToFitchain(userId: String?, pedometerData: CMPedometerData) {
        guard let url = URL(string: "http://148.100.108.176:3001/api/execute") else { return }
        let parameters: [String:Any]
        let request = NSMutableURLRequest(url: url)
        
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let args: [String] = [userId!, pedometerData.numberOfSteps.stringValue]
        parameters = ["type":"invoke", "params":["userId": userId!,"fcn": "generateFitcoins", "args":args]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let sendStepsToBlockchain = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized, let status = json["status"], let resultId = json["resultId"] {
                        NSLog(status as! String)
                        NSLog(resultId as! String) // Use this one to get blockchain payload
                        if status as! String == "success" {
                            
                            // Steps sent
                            self.sendingInProgress = false
                            
                            // Update steps that were used for conversion
                            let stepsUsedForConversion = pedometerData.numberOfSteps as! Int - ((pedometerData.numberOfSteps as! Int) % 100)
                            self.totalStepsConvertedToFitcoin = stepsUsedForConversion
                            
                            // Get state of user - should update fitcoins balance
                            self.getStateOfUser(userId!)
                        }
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        sendStepsToBlockchain.resume()
    }
    
    // This should get user profile from userId
    // The request is queued
    private func getStateOfUser(_ userId: String) {
        guard let url = URL(string: "http://148.100.108.176:3001/api/execute") else { return }
        let parameters: [String:Any]
        let request = NSMutableURLRequest(url: url)
        
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let args: [String] = [userId]
        parameters = ["type":"query", "params":["userId": userId,"fcn": "getState", "args":args]]
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
                        self.requestResults(resultId: resultId as! String, attemptNumber: 0)
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
    
    private func requestResults(resultId: String, attemptNumber: Int) {
        // recursive function limited to 60 attempts
        if attemptNumber < 60 {
            guard let url = URL(string: "http://148.100.108.176:3001/api/results/" + resultId) else { return }
            
            let session = URLSession.shared
            let resultsFromBlockchain = session.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        // data is
                        // {"status":"done","result":"{\"message\":\"success\",\"result\":\"{\\\"user\\\":\\\"4226e3af-5ae3-49bc-870c-886af9ec53a3\\\"}\"}"}
                        // Convert the data to JSON
                        
                        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        
                        if let json = jsonSerialized, let status = json["status"] {
                            NSLog(status as! String)
                            
                            // If status of our queued request is done
                            if status as! String == "done" {
                                let resultData = jsonSerialized!["result"]
                                NSLog(resultData as! String)
                                // {\"message\":\"success\",\"result\":\"{\\\"response\\\":\\\"{\\\\\\\"contractIds\\\\\\\":null,\\\\\\\"fitcoinsBalance\\\\\\\":0,\\\\\\\"id\\\\\\\":\\\\\\\"882adba4-37f5-4165-a373-c148428468f4\\\\\\\",\\\\\\\"memberType\\\\\\\":\\\\\\\"user\\\\\\\",\\\\\\\"stepsUsedForConversion\\\\\\\":0,\\\\\\\"totalSteps\\\\\\\":0}\\\"}\"}"}
                                
                                let resultSerialized = try JSONSerialization.jsonObject(with: (resultData as! String).data(using: .utf8)!, options: []) as? [String : Any]
                                
                                let anotherResultData = resultSerialized!["result"]
                                NSLog(anotherResultData as! String)
                                // {"response":"{\"contractIds\":null,\"fitcoinsBalance\":0,\"id\":\"882adba4-37f5-4165-a373-c148428468f4\",\"memberType\":\"user\",\"stepsUsedForConversion\":0,\"totalSteps\":0}"}
                                
                                let anotherResultSerialized = try JSONSerialization.jsonObject(with: (anotherResultData as! String).data(using: .utf8)!, options: []) as? [String : Any]
                                let userData = anotherResultSerialized!["response"]
                                // {"contractIds":null,"fitcoinsBalance":0,"id":"882adba4-37f5-4165-a373-c148428468f4","memberType":"user","stepsUsedForConversion":0,"totalSteps":0}
                                
                                let userDataSerialized = try JSONSerialization.jsonObject(with: (userData as! String).data(using: .utf8)!, options: []) as? [String : Any]
                                
                                // update variables
                                self.totalStepsConvertedToFitcoin = userDataSerialized!["stepsUsedForConversion"] as? Int
                                print(self.totalStepsConvertedToFitcoin!)
                                self.fitcoinsBalanceFromBlockchain = userDataSerialized!["fitcoinsBalance"] as? Int
                                print(self.fitcoinsBalanceFromBlockchain!)
                                
                                // Update fitcoins of user
                                DispatchQueue.main.async {
                                    self.fitcoinsLabel.text = String(describing: self.fitcoinsBalanceFromBlockchain!)
                                }
                            }
                            else {
                                let when = DispatchTime.now() + 3 // 3 seconds from now
                                DispatchQueue.main.asyncAfter(deadline: when) {
                                    self.requestResults(resultId: resultId, attemptNumber: attemptNumber+1)
                                }
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
}

