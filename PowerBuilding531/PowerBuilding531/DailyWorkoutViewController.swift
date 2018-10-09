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
    
    @IBOutlet weak var workoutPicker: UIPickerView!
    @IBOutlet weak var workoutDisplayText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var finishWorkoutFab: MDCFloatingButton!
    
    var pickerData: [String] = [String]()
    var workoutData: [String] = [String]()
    var workoutSetData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColor()
        workoutPicker.isHidden = true
        initPicker()
        initWorkout()
        
        finishWorkoutFab.backgroundColor = UIColor(red:0.00, green:0.57, blue:0.92, alpha:1.0)
        finishWorkoutFab.setImage(UIImage(named: "check.png"), for: .normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setStatusBarColor() {
        UINavigationBar.appearance().clipsToBounds = true
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0)
    }
    
    func initPicker() {
        pickerData = ["Today - Deadlift", "Week 4 Bench Press - 10/06/2018", "Week 4 Squat - 10/5/2018"]
        workoutDisplayText.text = pickerData.first
        workoutDisplayText.delegate = self
        workoutPicker.delegate = self
        workoutPicker.dataSource = self
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
        pickerView.isHidden = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        workoutPicker.isHidden = false
        return false
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
            print("uploadWorkout")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    @IBAction func onLogoutClicked(_ sender: Any) {
        try! Auth.auth().signOut()
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginID")
        self.present(controller, animated: true)
    }
    
}
