//
//  OnboardingViewController.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/8/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import MaterialComponents.MaterialAppBar

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

class OnboardingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var formTableView: UITableView!
    
    final let formLabels = ["Back Squat", "Front Squat", "Deadlift", "Clean", "Bench Press", "Close-grip bench", "Overhead Press", "Z Press"]
    
    var userMaxes: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...7 {
            userMaxes.append("")
        }
        
        formTableView.dataSource = self
        formTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        formTableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(notification:)),
            name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(notification:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "onboarding")!  as! OnboardingFormCell
        
        cell.label.text = formLabels[indexPath.row]
        
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
        
        cell.textField.inputAccessoryView = toolBar
        cell.textField.text = userMaxes[indexPath.row]
        cell.textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingDidEnd)
        
        return cell
    }

    @IBAction func onSubmit(_ sender: Any) {
        // write to firebase and open daily workout
        let key = Auth.auth().currentUser?.uid
        let post = ["back_squat": userMaxes[0],
                    "front_squat": userMaxes[1],
                    "deadlift": userMaxes[2],
                    "clean": userMaxes[3],
                    "bench_press": userMaxes[4],
                    "close_grip_bench_press": userMaxes[5],
                    "overhead_press": userMaxes[6],
                    "z_press": userMaxes[7]]
        Database.database().reference().child("one_rep_maxes").child(key!).updateChildValues(post as [AnyHashable : Any]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Onboarding - onSubmit - Data could not be saved: \(error).")
            } else {
                print("Onboarding - onSubmit - Data saved successfully!")
                self.openDailyWorkout()
            }
        }
    }
    
    func openDailyWorkout() {
        let storyboard = UIStoryboard(name: "DailyWorkout", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DailyWorkoutID")
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.2, animations: {
                self.formTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.formTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    @objc func doneClick() {
        dismissKeyboard()
    }
    
    @objc func cancelClick() {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        let rowIndex: Int
        let cell = sender.superview?.superview as! OnboardingFormCell
        rowIndex = (formTableView.indexPath(for: cell)?.row)!
        userMaxes[rowIndex] = cell.textField.text!
    }
}
