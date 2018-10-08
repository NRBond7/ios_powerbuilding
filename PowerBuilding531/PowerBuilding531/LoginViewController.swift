//
//  LoginViewController.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/5/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate {
    
    let authUI = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        self.authUI?.providers = providers
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let viewController = authUI?.authViewController()
        self.present(viewController!, animated: true)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil {
            Database.database().reference().child("one_rep_maxes").child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.openDailyWorkout()
                } else {
                    self.openOnboarding()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
            case FUIAuthErrorCode.userCancelledSignIn.rawValue:
                print("User cancelled sign-in");
                break
            
            default:
                let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
                print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
    func openOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingID")
        self.present(controller, animated: true, completion: nil)
    }
    
    func openDailyWorkout() {
        let storyboard = UIStoryboard(name: "DailyWorkout", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DailyWorkoutID")
        self.present(controller, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
