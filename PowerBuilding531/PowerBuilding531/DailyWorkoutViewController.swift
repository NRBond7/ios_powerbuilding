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
    
    var workoutPicker: UIPickerView = UIPickerView()
    
    var pickerStrings: [String] = [String]()
    var pickerTypes: [String] = [String]()
    var workoutData: Dictionary<String, Array<String>> = Dictionary<String, Array<String>>()
    var workoutSetData: [String] = [String]()
    var databaseRef: DatabaseReference!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColor()
        setupFirebase()
        tableView.isHidden = true
        
        finishWorkoutFab.backgroundColor = Colors().BLUE
        finishWorkoutFab.setImage(UIImage(named: "check.png"), for: .normal)
    }
    
    func setupFirebase() {
        databaseRef = Database.database().reference()
        user = Auth.auth().currentUser!
        
        databaseRef.child("lift_log").child(user.uid).observe(.value) { snapshot in
            var lastLift = ""
            
            if snapshot.childrenCount > 0 {
                var workoutCount = 1.0
                for case let child as DataSnapshot in snapshot.children {
                    let val = child.value
                    if let childData = val as? Dictionary<String, String> {
                        let liftDate = childData["date"]
                        let liftName = childData["lift_name"]
                        let liftType = childData["lift_type"]
                        let weekNumber = Int(Double(workoutCount / 4.0).rounded(.up))
                        
                        var workoutString = "Week " + String(weekNumber)
                        workoutString = workoutString + " " + liftName!
                        workoutString  = workoutString + " - " + liftDate!
                        self.pickerStrings.insert(workoutString, at: 0)
                        self.pickerTypes.insert(liftType!, at: 0)
                        lastLift = liftType!
                    }
                    
                    workoutCount = workoutCount + 1;
                }
            }
            
            let defaults = UserDefaults.standard
            let nextLift = LiftUtil().generateNextLiftDay(lastLift: lastLift)
            let nextLiftText = "Today - " + nextLift["liftName"]!
            self.workoutDisplayText.text = nextLiftText
            self.pickerStrings.insert(nextLiftText, at: 0)
            self.pickerTypes.insert(nextLift["liftType"]!, at: 0)
            
            defaults.set(nextLift, forKey: "nextLift")
            self.initPicker()
            self.loadDataForDay(nextLift: nextLift)
        }
    }
    
    func loadDataForDay(nextLift: Dictionary<String, String>) {
        workoutHeaderText.text = nextLift["liftName"]! + " Day"
        workoutDisplayText.text = "Today - " + nextLift["liftName"]!
        populateLiftUI(nextLift: nextLift)
    }
    
    func populateLiftUI(nextLift: Dictionary<String, String>) {
        let picker = workoutDisplayText.inputView as! UIPickerView
        let index = picker.selectedRow(inComponent: 0)
        let workoutNumber = pickerStrings.count - index
        let weekNumber = Int(ceil(Double(workoutNumber) / 4.0))
        let wave = Int(floor(Double(weekNumber - 1) / 3.0 + 1))

        let weekId: String
        switch(weekNumber) {
        case 1, 4, 7:
            weekId = "147";
            break;
        case 2, 5, 8:
            weekId = "258";
            break;
        case 3, 6, 9:
            weekId = "369";
            break;
        default:
            weekId = "147";
            break;
        }

        print("workout - " + String(workoutNumber));
        print("week - " + String(weekNumber));
        print("wave - " + String(wave));
        print("weekid - " + String(weekId));

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "patternData")
        defaults.removeObject(forKey: "waveData")
        defaults.removeObject(forKey: "maxData")
        defaults.removeObject(forKey: "liftBlockData")
        defaults.removeObject(forKey: "liftBlockTypeData")
        
        databaseRef.child("pattern").child(weekId).child(nextLift["liftType"]!).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, Dictionary<String, String>> else { print("pattern failed"); return }
            defaults.set(dictionary, forKey: "patternData")
            self.generateWorkout()
        }

        databaseRef.child("waves").child(String(wave)).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, Dictionary<String, Double>> else { print("waves failed"); return }
            defaults.setValue(dictionary, forKey: "waveData")
            self.generateWorkout()
        }

        databaseRef.child("one_rep_maxes").child(user.uid).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, String> else { print("one_rep_maxes failed"); return }
            defaults.setValue(dictionary, forKey: "maxData")
            self.generateWorkout()
        }

        databaseRef.child("lift_blocks").child(nextLift["liftType"]!).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? Dictionary<String, Array<Dictionary<String, Any>>> else { print("lift_blocks failed"); return }
            defaults.setValue(dictionary, forKey: "liftBlockData")
            self.generateWorkout()
        }

        databaseRef.child("lift_block_types").observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? Array<Dictionary<String, Any>> else { print("lift_block_types failed"); return }
            defaults.setValue(dictionary, forKey: "liftBlockTypeData")
            self.generateWorkout()
        }
    }
    
    func generateWorkout() {
        let defaults = UserDefaults.standard
        guard let patternData = defaults.object(forKey: "patternData") as? Dictionary<String, Dictionary<String, String>> else { return }
        guard let waveData = defaults.object(forKey: "waveData") as? Dictionary<String, Dictionary<String, Double>> else { return }
        guard let maxData = defaults.object(forKey: "maxData") as? Dictionary<String, String> else { return }
        guard let liftBlockData = defaults.object(forKey: "liftBlockData") as? Dictionary<String, Array<Dictionary<String, Any>>> else { return }
        guard let liftBlockTypeData = defaults.object(forKey: "liftBlockTypeData") as? Array<Dictionary<String, Any>> else { return }
        
        var liftBlockIndex = 0
        for blockType in liftBlockTypeData {
            let currentBlockId = blockType["id"] as! String
            let numSets = blockType["num_sets"] as! Int
            workoutData[currentBlockId] = Array<String>()

            for setIndex in 0...numSets-1 {
                let currentSetNumber = setIndex + 1;
                guard let liftBlock = liftBlockData[currentBlockId] else { print("liftBlock failed"); return }

                var liftBlockDataIndex = 0
                for _ in liftBlock {
                    guard let patternBlock = patternData[currentBlockId] else { print("patternBlock failed"); return }
                    guard let intensity = patternBlock["intensity"] else { print("intensity failed"); return }
                    let liftType = liftBlock[liftBlockDataIndex]["lift_type"] as! String
                    let liftName = liftBlock[liftBlockDataIndex]["lift_name"] as! String
                    let hasPr = liftBlock[liftBlockDataIndex]["has_pr"] as! Bool
                    guard let waveBlock = waveData[intensity] else { return }
                    let reps = Int(waveBlock["set_" + String(currentSetNumber) + "_reps"]!)

                    if (hasPr) {
                        guard let liftMax = maxData[liftType] else { return }
                        guard let weightPercentage = waveBlock["set_" + String(currentSetNumber) + "_percentage"] else { print("weightPercentage failed"); return }
                        let liftWeight = LiftUtil().roundDownCalculation(value: Double(liftMax)! * Double(weightPercentage))
                        let lift = String(liftWeight) + " x " + String(reps) + " " + liftName
                         workoutData[currentBlockId]?.append(lift)
                    } else {
                        workoutData[currentBlockId]?.append(liftName)
                    }

                    liftBlockDataIndex = liftBlockDataIndex + 1
                }
            }
            liftBlockIndex = liftBlockIndex + 1
        }

        self.initWorkout()
        
        tableView.isHidden = false
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
        return pickerStrings.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerStrings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let workout = LiftUtil().getLiftDictionary(liftType : pickerTypes[row])
        workoutDisplayText.text = pickerStrings[row]
        workoutHeaderText.text = workout["liftName"]! + " Day"
        populateLiftUI(nextLift: workout)
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
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "conditioningCard")!  as! ConditioningCardCell
            cell.lift1.text = workoutData["conditioning"]?[0]
            let lift2Text: String
            if workoutData["conditioning"]?.count ?? 0 > 1 {
                lift2Text = workoutData["conditioning"]?[1] ?? ""
            } else {
                lift2Text = ""
            }
            cell.lift2.text = lift2Text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCard")!  as! CardTableViewCell
            let headerText: String
            let cellType: String
            if indexPath.row == 0 {
                headerText = "Primary"
                cellType = "primary"
            } else {
                headerText = "Assitance"
                cellType = "assistance"
            }
            cell.headerText.text = headerText
            
            cell.set1WarmUp.text = workoutData[cellType]?[0]
            cell.set1MainLift.text = workoutData[cellType]?[1]
            cell.set1Core.text = workoutData[cellType]?[2]
            
            cell.set2WarmUp.text = workoutData[cellType]?[3]
            cell.set2MainLift.text = workoutData[cellType]?[4]
            cell.set2Core.text = workoutData[cellType]?[5]
            
            cell.set3WarmUp.text = workoutData[cellType]?[6]
            cell.set3MainLift.text = workoutData[cellType]?[7]
            cell.set3Core.text = workoutData[cellType]?[8]
            return cell
        }
    }
    
    @IBAction func handleFinishWorkout(_ sender: Any) {
        if (workoutPicker.selectedRow(inComponent: 0) == 0) {
            let alertController = UIAlertController(title: "Upload workout?", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Upload", style: .default, handler: { action in
                print("handleFinishWorkout")
                let defaults = UserDefaults.standard
                let lift = defaults.dictionary(forKey: "nextLift")
                let date = Date()
                let day = Calendar.current.component(.day, from: date)
                let month = Calendar.current.component(.month, from: date)
                let year = Calendar.current.component(.year, from: date)
                let dateString = String(month) + "/" + String(day) + "/" + String(year)
                let post: [String : String] = ["date": dateString,
                                               "lift_name": lift!["liftName"] as! String,
                                               "lift_type": lift!["liftType"] as! String,
                                               "lift_pr": String(100),
                                               "was_skipped": String(false)]
                self.databaseRef.child("lift_log").child(self.user.uid).childByAutoId().updateChildValues(post) {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("DailyWorkout - handleFinishWorkout - Data could not be saved: \(error).")
                    } else {
                        print("DailyWorkout - handleFinishWorkout - Data saved successfully!")
                    }
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
        }
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
