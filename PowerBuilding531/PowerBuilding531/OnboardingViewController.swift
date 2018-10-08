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

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var backSquat: UITextField!
    @IBOutlet weak var frontSquat: UITextField!
    @IBOutlet weak var deadlift: UITextField!
    @IBOutlet weak var clean: UITextField!
    @IBOutlet weak var benchPress: UITextField!
    @IBOutlet weak var closeGrip: UITextField!
    @IBOutlet weak var overheadPress: UITextField!
    @IBOutlet weak var zPress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func onSubmit(_ sender: Any) {
        let backSquatPR = backSquat?.text!.toDouble()
        let frontSquatPR = frontSquat?.text!.toDouble()
        let deadliftPR = deadlift?.text!.toDouble()
        let cleanPR = clean?.text!.toDouble()
        let benchPressPR = benchPress?.text!.toDouble()
        let closeGripPR = closeGrip?.text!.toDouble()
        let overheadPressPR = overheadPress?.text!.toDouble()
        let zPressPR = zPress?.text!.toDouble()
        
        // write to firebase and open daily workout
        let key = Auth.auth().currentUser?.uid
        let post = ["back_squat": backSquatPR,
                    "front_squat": frontSquatPR,
                    "deadlift": deadliftPR,
                    "clean": cleanPR,
                    "bench_press": benchPressPR,
                    "close_grip_bench_press": closeGripPR,
                    "overhead_press": overheadPressPR,
                    "z_press": zPressPR]
        Database.database().reference().child("one_rep_maxes").child(key!).updateChildValues(post) {
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
}
