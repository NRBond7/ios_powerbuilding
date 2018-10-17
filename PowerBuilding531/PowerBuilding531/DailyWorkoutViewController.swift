//
//  DailyWorkoutViewController.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/5/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialFlexibleHeader
import Firebase

class DailyWorkoutViewController: UIViewController, UIPickerViewDelegate,
        UIPickerViewDataSource, UITextFieldDelegate,
        UITableViewDataSource {
    
    @IBOutlet weak var workoutDisplayText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var finishWorkoutFab: MDCFloatingButton!
    @IBOutlet weak var workoutHeaderText: UITextField!
    
    var pickerData: [String] = [String]()
    var workoutData: [String] = [String]()
    var workoutSetData: [String] = [String]()
    var databaseRef: DatabaseReference!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColor()
//        initPicker()
//        initWorkout()
        setupFirebase()
        
        finishWorkoutFab.backgroundColor = Colors().BLUE
        finishWorkoutFab.setImage(UIImage(named: "check.png"), for: .normal)
    }
    
    func setupFirebase() {
        databaseRef = Database.database().reference()
        user = Auth.auth().currentUser!
        
        databaseRef.child("lift_log").child(user.uid).observe(.value) { snapshot in
            var lastLift = ""
            
            if snapshot.childrenCount > 0 {
                var workoutCount = 1.0;
                for case let child as DataSnapshot in snapshot.children {
                    let val = child.value
                    if let childData = val as? Dictionary<String, String> {
                        let liftDate = childData["date"]
                        let liftName = childData["lift_name"]
                        let liftType = childData["lift_type"]
                        let weekNumber = round(workoutCount / 4.0)
                        
                        var workoutString = "Week " + String(weekNumber)
                        workoutString = workoutString + " " + liftName!
                        workoutString  = workoutString + " - " + liftDate!
                        self.pickerData.append(workoutString)
                        lastLift = liftType!
                    }
                    
                    workoutCount = workoutCount + 1;
                }
            }
            
            let defaults = UserDefaults.standard
            let nextLift = LiftUtil().generateNextLiftDay(lastLift: lastLift)
            let nextLiftText = "Today - " + nextLift["liftName"]!
            self.pickerData.insert(nextLiftText, at: 0)
            
            defaults.set(nextLift, forKey: "nextLift")
            self.initPicker()
//            self.loadDataForDay(nextLift: nextLift)
            self.initWorkout()
        }
    }
    
    func loadDataForDay(nextLift: Dictionary<String, String>) {
        workoutHeaderText.text = nextLift["liftName"]! + " Day"
        populateLiftUI(nextLift: nextLift)
    }
    
    func populateLiftUI(nextLift: Dictionary<String, String>) {
//        let index = workoutPicker.selectedRow(inComponent: 0)
//        let workoutNumber = pickerData.count - index
//        let weekNumber = Int(ceil(Double(workoutNumber) / 4.0))
//        let wave = Int(floor(Double(weekNumber - 1) / 3.0 + 1))
//
//        let weekId: String
//        switch(weekNumber) {
//        case 1, 4, 7:
//            weekId = "147";
//            break;
//        case 2, 5, 8:
//            weekId = "258";
//            break;
//        case 3, 6, 9:
//            weekId = "369";
//            break;
//        default:
//            weekId = "147";
//            break;
//        }
//
//        print("workout - " + String(workoutNumber));
//        print("week - " + String(weekNumber));
//        print("wave - " + String(wave));
//        print("weekid - " + String(weekId));
//
//        let defaults = UserDefaults.standard
//        databaseRef.child("pattern").child(weekId).child(nextLift["liftType"]!).observe(.value) { snapshot in
//            let dictionary = snapshot.value as? [String: [String:String]]
//            defaults.setValue(dictionary, forKey: "patternData")
//            self.generateWorkout()
//        }
//
//        databaseRef.child("waves").child(String(wave)).observe(.value) { snapshot in
//            let dictionary = snapshot.value as? [String: Any]?
//            defaults.setValue(dictionary, forKey: "waveData")
//            self.generateWorkout()
//        }
//
//        databaseRef.child("one_rep_maxes").child(user.uid).observe(.value) { snapshot in
//            let dictionary = snapshot.value as? [String: Any]
//            defaults.setValue(dictionary, forKey: "maxData")
//            self.generateWorkout()
//        }
//
//        databaseRef.child("lift_blocks").child(nextLift["liftType"]!).observe(.value) { snapshot in
//            let dictionary = snapshot.value as? [String: Any]
//            defaults.setValue(dictionary, forKey: "liftBlockData")
//            self.generateWorkout()
//        }
//
//        databaseRef.child("lift_block_types").observe(.value) { snapshot in
//            let dictionary = snapshot.value as? Array<Any>
//            defaults.setValue(dictionary, forKey: "liftBlockTypeData")
//            self.generateWorkout()
//        }
    }
    
    func generateWorkout() {
        let defaults = UserDefaults.standard
        let patternData = defaults.object(forKey: "patternData") as! [String: [String:String]]?
        let waveData = defaults.object(forKey: "waveData") as! [String: Any]?
        let maxData = defaults.object(forKey: "maxData") as! [String: Any]?
        let liftBlockData = defaults.object(forKey: "liftBlockData") as! [String: Any]?
        let liftBlockTypeData = defaults.object(forKey: "liftBlockTypeData") as! Array<Any>?
        
        if patternData != nil && waveData != nil && maxData != nil && liftBlockData != nil && liftBlockTypeData != nil {
            var liftBlockIndex = 0

            for blockType in liftBlockTypeData! {
                let castedBlock = blockType as! [String : String]
                let currentBlockId = castedBlock["id"]!;
                let currentBlockName = castedBlock["name"]!;
                let numSets = castedBlock["num_sets"]!;
                
                var setIndex = 0;
                for o in numSets {
                    var currentSet = setIndex + 1;
                    
                    var liftBlockDataIndex = 0
                    for liftBlock in liftBlockData! {
                        let patternBlock = patternData![currentBlockId]! as Dictionary<String, String>
                        let intensity = patternBlock["intensity"]!;
                        let liftBlock = liftBlockData![currentBlockId]! as! Dictionary<String, Dictionary<String, String>>
                        let liftType = liftBlock[String(liftBlockDataIndex)]!["lift_type"]!;
                        let liftName = liftBlock[String(liftBlockDataIndex)]!["lift_name"]!;
                        let hasPr = liftBlock[String(liftBlockDataIndex)]!["has_pr"]!;
                        let waveBlock = waveData![intensity] as! Dictionary<String, String>
                        let reps = waveBlock["set_" + String(currentSet) + "_reps"]!;
                        
                        if (hasPr == "true") {
                            let maxBlock = maxData as! Dictionary<String, String>
                            var liftMax = maxBlock[liftType]!;
                            var weightPercentage = waveBlock["set_" + String(currentSet) + "_percentage"]!;
                            let liftWeight = LiftUtil().roundDownCalculation(value: Double(liftMax)! * Double(weightPercentage)!);
                            let lift = String(liftWeight) + " x " + String(reps) + " " + liftName
                            workoutData.append(lift)
                        } else {
                            let lift = reps + " " + liftName
                            workoutData.append(lift)
                        }
                        
                        liftBlockDataIndex = liftBlockDataIndex + 1
                    }
                    setIndex = setIndex + 1
                }
                liftBlockIndex = liftBlockIndex + 1
            }
            
            self.initWorkout()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setStatusBarColor() {
        UINavigationBar.appearance().clipsToBounds = true
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = Colors().RED
    }
    
    func initPicker() {
        let workoutPicker: UIPickerView
        workoutPicker = UIPickerView()
        workoutPicker.backgroundColor = .white
        workoutPicker.showsSelectionIndicator = true
        workoutPicker.delegate = self
        workoutPicker.dataSource = self
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Colors().BLUE
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        workoutDisplayText.inputView = workoutPicker
        workoutDisplayText.inputAccessoryView = toolBar
        workoutDisplayText.tintColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        workoutDisplayText.text = pickerData[row]
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.initPicker()
        return false
    }
    
    @objc func doneClick() {
        workoutDisplayText.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        workoutDisplayText.resignFirstResponder()
    }
    
    func initWorkout() {
        for i in 1...3 {
            workoutData.append("\(i)")
        }
        for i in 1...3 {
            workoutSetData.append("\(i)")
        }
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.allowsSelection = false
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.item == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCard")!  as! ConditioningCardCell
            cell.lift1.text = "Lift 1"
            cell.lift2.text = "Lift 2"
            cell.lift3.text = "Lift 3"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCard")!  as! CardTableViewCell
            let headerText: String
            if indexPath.item == 0 {
                headerText = "Primary"
            } else {
                headerText = "Secondary"
            }
            cell.headerText.text = headerText
            
            cell.set1WarmUp.text = "Warm up 1"
            cell.set1MainLift.text = "Main 1"
            cell.set1Core.text = "Core 1"
            
            cell.set2WarmUp.text = "Warm up 2"
            cell.set2MainLift.text = "Main 2"
            cell.set2Core.text = "Core 2"
            
            cell.set3WarmUp.text = "Warm up 3"
            cell.set3MainLift.text = "Main 3"
            cell.set3Core.text = "Core 3"
            return cell
        }
    }
    
    @IBAction func handleFinishWorkout(_ sender: Any) {
        // todo: upload workout
        let alertController = UIAlertController(title: "Upload workout?", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Upload", style: .default, handler: { action in
            print("handleFinishWorkout")
//            let defaults = UserDefaults.standard
//            let lift = defaults.dictionary(forKey: "nextLift")
//            let key = self.user.uid
//            let post: [String : String] = ["date": "10/08/2018",
//                                           "lift_name": lift!["liftName"] as! String,
//                                           "lift_type": lift!["liftType"] as! String,
//                                            "lift_pr": String(100),
//                                            "was_skipped": String(false)]
//            self.databaseRef.child("lift_log").child(key).updateChildValues(post) {
//                (error:Error?, ref:DatabaseReference) in
//                if let error = error {
//                    print("DailyWorkout - handleFinishWorkout - Data could not be saved: \(error).")
//                } else {
//                    print("DailyWorkout - handleFinishWorkout - Data saved successfully!")
//                }
//            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    @IBAction func onLogoutClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout?", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            try! Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginID")
            self.present(controller, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
}
