//
//  ViewController.swift
//  iHealthProject
//
//  Created by HealthJudge on 2018/4/20.
//  Copyright © 2018年 HealthHIT. All rights reserved.
//

import UIKit
import HealthKit
import WebKit

class ViewController: UIViewController, WKUIDelegate{
    var url : String?
    
    var email:String?
    
    var name:String?
    var sex:String?
    var weight:Double?
    var height:Double?
    var birthday:Date?
    
    @IBOutlet weak var showName: UILabel!
    @IBOutlet weak var showSex: UILabel!
    @IBOutlet weak var showWeight: UILabel!
    @IBOutlet weak var showHeight: UILabel!
    @IBOutlet weak var showBirth: UILabel!
    
    @IBAction func loadStep(sender:AnyObject) {
        url = "http://39.106.156.178/iHealth/4.png"
    }
    
    @IBAction func loadHearRate(sender:AnyObject) {
        url = "https://www.apple.com"
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webVC = segue.destination as? WebUIController {
            webVC.url = URL(string:url!)
        }
    }
    
    //以下为登陆内容
    @IBOutlet weak var loginUserName: UITextField!
    
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBAction func loginClicked(_ sender: UIButton) {
        email = loginUserName.text!
        var userName:String = loginUserName.text!
        var password:String = loginPassword.text!
        var url:URL = URL(string: "http://39.106.156.178/test.php")!
        var postString="name=\(userName)&password=\(password)"
        postRequest(url: url, postString: postString)
    }
    //signup
    @IBOutlet weak var singupName: UITextField!
    @IBOutlet weak var signupEmail: UITextField!
    @IBOutlet weak var signupPassword: UITextField!
    @IBOutlet weak var signupWeight: UITextField!
    @IBOutlet weak var signupHeight: UITextField!
    @IBOutlet weak var signupBirthday: UIDatePicker!
    @IBOutlet weak var signupSex: UISegmentedControl!
    @IBAction func signupClicked(_ sender: UIButton) {
        var url:URL = URL(string: "http://39.106.156.178/test.php")!
        var postString:String = "name=\(singupName.text!)&email=\(signupEmail.text!)&password=\(signupPassword.text!)&weight=\(signupWeight.text!)&height=\(signupHeight.text!)&birthday=\(signupBirthday.date)&sex=\(signupSex.selectedSegmentIndex)"
        postRequest(url: url, postString: postString)
    }/*
    @IBOutlet weak var editName: UITextField!
    @IBOutlet weak var editWeight: UITextField!
    @IBOutlet weak var editHeight: UITextField!*/
    @IBAction func profileEdit(_ sender: UIButton) {
        /*var postString:String = "name=\(editName.text!)&weight=\(editWeight.text!)&height=\(editHeight.text!)"
        var url:URL = URL(string: "http://39.106.156.178/test.php")!
        postRequest(url: url, postString: postString)*/
    }
    
    func postRequest(url:URL,postString:String){

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: .utf8)
    
        let task = URLSession.shared.dataTask(with: request as URLRequest,completionHandler:{ data,response,error in
            guard error == nil else{
                return
            }
            guard let data = data else{
                return
            }
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                    DispatchQueue.main.async {
                        [unowned self] in
                        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateInitialViewController() as UIViewController!
                        self.present(vc!, animated: true)
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    //登陆内容结束
    //请求信息

    @IBAction func getProfile(_ sender: UIButton) {
        /*var postString:String = "APPLEID=\(email!)"
        var url:URL = URL(string: "http://39.106.156.178/test.php")!
        requestProfile(url: url, postString: postString)*/
    }
    func requestProfile(url:URL,postString:String){
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest,completionHandler:{ data,response,error in
            guard error == nil else{
                return
            }
            guard let data = data else{
                return
            }
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                    self.name = json["Name"] as? String
                    self.sex = json["Sex"] as? String
                    self.weight = json["Weight"] as? Double
                    self.height = json["Height"] as? Double
                    self.birthday = json["Birthday"] as? Date
                    self.showName.text=self.name
                    self.showSex.text = self.sex
                    self.showWeight.text = String(describing: self.weight)
                    self.showHeight.text = String(describing: self.height)
                    self.showBirth.text = String(describing: self.birthday)
                    self.saveUserData()
                }
            }catch let error{
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    
    @IBAction func backToLogin(sender : AnyObject) {
        print("Button1")
        let vc = UIStoryboard(name:"Login", bundle:nil).instantiateInitialViewController() as UIViewController!
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func btnBack(sender:AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //下尝试改变信息
    @IBAction func weightTextFieldEdited(_ sender: Any) {
        /*guard let nextText = weightTextField.text,let newWeight = Double(newText)else{
            return
        }
        weight = newWeight*/
    }
    
    //尝试结束
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        askForHealthKitAccess()
    }

    private var bodyMassIndex: Double? = nil{
        didSet{
            //forlater
        }
    }
    
    private func saveUserData(){
        
        guard let weight = weight,
            let height = height,
            let bodyMassIndex = bodyMassIndex else{
                return
        }
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass),
            let heightType = HKQuantityType.quantityType(forIdentifier: .height),
            let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else{
                print("Something horrible has happened.")
                return
        }
        let weightQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: weight)
        let heightQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: height)
        let bodyMassIndexQuantity = HKQuantity(unit:HKUnit.count(),doubleValue:bodyMassIndex)
        
        //Save Data
        var errorOccurred = false
        HealthKitController.sharedInstance.writeSample(for: weightType, sampleQuantity: weightQuantity) { (success, error) in
            if !success, let error = error {
                errorOccurred = true
                print(error.localizedDescription)
            }
        }
        HealthKitController.sharedInstance.writeSample(for: heightType, sampleQuantity: heightQuantity) { (success, error) in
            if !success, let error = error {
                errorOccurred = true
                print(error.localizedDescription)
            }
        }
        HealthKitController.sharedInstance.writeSample(for: bodyMassIndexType, sampleQuantity: bodyMassIndexQuantity) { (success, error) in
            if !success, let error = error {
                errorOccurred = true
                print(error.localizedDescription)
            }
        }
        //Error Handling
        if errorOccurred{
            showAlert(title: "Failed to Save Data", message: "Some error occured while wrigint to HealthKit")
        }else{
            showAlert(title: "Success", message: "Successfully saved your data to HealthKit")
        }
    }
    
    private func readWeightAndHeight(){
        guard let heightType = HKSampleType.quantityType(forIdentifier: .height),
            let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else{
                print("Something horrible has happened.")
                return
        }
        HealthKitController.sharedInstance.readMostRecentSample(for: heightType) { (sample, error) in
            if let sample = sample {
                self.height = sample.quantity.doubleValue(for: HKUnit.foot())
            }
        }
        HealthKitController.sharedInstance.readMostRecentSample(for: weightType) { (sample, error) in
            if let sample = sample {
                self.weight = sample.quantity.doubleValue(for: HKUnit.pound())
            }
        }
    }
    
    private func askForHealthKitAccess() {
        
        HealthKitController.sharedInstance.aurhorizeHealthKit { (success, error) in
            if !success, let error = error {
                self.showAlert(title: "HealthKit Authentication Failed", message: error.localizedDescription)
            } else {
                self.readWeightAndHeight()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class HealthKitController:NSObject{
    
    static let sharedInstance = HealthKitController()
    private enum HealthKitcontrollerError:Error{
        case DeviceNotSupported
        case DataTypeNotAvailable
    }
    private let healthStore = HKHealthStore()
    func aurhorizeHealthKit(completion:@escaping(Bool,Error?) -> Void){
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false,HealthKitcontrollerError.DeviceNotSupported)
            return
        }
        
        guard
            let weight = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            let flightCount = HKObjectType.quantityType(forIdentifier: .flightsClimbed) else{
                completion(false,HealthKitcontrollerError.DataTypeNotAvailable)
                return
        }
        
        let dataToWrite: Set<HKSampleType> = [
            weight,
            height,
            bodyMassIndex
        ]
        let dataToRead:Set<HKSampleType> = [
            weight,
            height,
            stepCount,
            distance,
            flightCount
        ]
        healthStore.requestAuthorization(toShare: dataToWrite, read: dataToRead, completion: { (success,error) in completion(success,error)})
    }
    
    func readMostRecentSample(for type: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let mostRecentSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [mostRecentSortDescriptor]) { (query, result, error) in
            
            DispatchQueue.main.async {
                guard let samples = result as? [HKQuantitySample], let sample = samples.first else {
                    completion(nil, error)
                    return
                }
                completion(sample, nil)
            }
        }
        
        healthStore.execute(sampleQuery)
    }
    
    func writeSample(for quantityType: HKQuantityType, sampleQuantity: HKQuantity, completion: @escaping (Bool, Error?) -> Void) {
        
        let sample = HKQuantitySample(type: quantityType, quantity: sampleQuantity, start: Date(), end: Date())
        healthStore.save(sample) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    private func readActivitiesData(){
        guard let stepType = HKSampleType.quantityType(forIdentifier: .stepCount),
            let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
            let flightType = HKSampleType.quantityType(forIdentifier: .flightsClimbed)else{
                print("something horrible is happened")
                return
        }
    }
}

