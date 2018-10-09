//
//  ViewController.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/5/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if user == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginID")
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        } else {
            self.openDailyWorkout()
            
//            Database.database().reference().child("one_rep_maxes").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                if snapshot.exists() {
//                    self.openDailyWorkout()
//                } else {
//                    self.openOnboarding()
//                }
//            }) { (error) in
//                print(error.localizedDescription)
//            }
        }
    }
    
    func openDailyWorkout() {
        let storyboard = UIStoryboard(name: "DailyWorkout", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DailyWorkoutID")
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    func openOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingID")
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

