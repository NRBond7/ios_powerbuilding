//
//  ViewController.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/5/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    @IBOutlet weak var loginButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        let preferences = UserDefaults.init()
        let hasSignedInKey = "hasSignedIn"
        
        if preferences.object(forKey: hasSignedInKey) == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginID")
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "DailyWorkout", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DailyWorkoutID")
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
}

