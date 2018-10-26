//
//  LiftUtil.swift
//  PowerBuilding531
//
//  Created by Bond, Noah on 10/9/18.
//  Copyright © 2018 Bond, Noah. All rights reserved.
//

import Foundation

class LiftUtil {
    func generateNextLiftDay(lastLift: String) -> Dictionary<String, String> {
        var dictionary = Dictionary<String, String>()
        if (!lastLift.isEmpty) {
            switch (lastLift) {
                case "deadlift":
                    dictionary["liftType"] = "overhead_press"
                    dictionary["liftName"] = "OHP"
                    break
                case "overhead_press":
                    dictionary["liftType"] = "back_squat"
                    dictionary["liftName"] = "Back Squat"
                    break
                case "back_squat":
                    dictionary["liftType"] = "bench_press"
                    dictionary["liftName"] = "Bench Press"
                    break
                case "bench_press":
                    dictionary["liftType"] = "deadlift"
                    dictionary["liftName"] = "Deadlift"
                    break
                default:
                    dictionary["liftType"] = "deadlift"
                    dictionary["liftName"] = "Deadlift"
                    break
            }
        } else {
            dictionary["liftType"] = "deadlift"
            dictionary["liftName"] = "Deadlift"
        }
        
        return dictionary
    }
    
    func getLiftDictionary(liftType: String) -> Dictionary<String, String> {
        var dictionary = Dictionary<String, String>()
        if (!liftType.isEmpty) {
            switch (liftType) {
            case "deadlift":
                dictionary["liftType"] = "deadlift"
                dictionary["liftName"] = "Deadlift"
                break
            case "overhead_press":
                dictionary["liftType"] = "overhead_press"
                dictionary["liftName"] = "Overhead Press"
                break
            case "back_squat":
                dictionary["liftType"] = "back_squat"
                dictionary["liftName"] = "Back Squat"
                break
            case "bench_press":
                dictionary["liftType"] = "bench_press"
                dictionary["liftName"] = "Bench Press"
                break
            default:
                dictionary["liftType"] = "deadlift"
                dictionary["liftName"] = "Deadlift"
                break
            }
        } else {
            dictionary["liftType"] = "deadlift"
            dictionary["liftName"] = "Deadlift"
        }
        
        return dictionary
    }
    
    func roundDownCalculation(value: Double) -> Double {
        return 2.5 * floor(value / 2.5);
    }

}
