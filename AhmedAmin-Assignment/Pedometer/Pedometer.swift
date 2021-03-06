//
//  Pedometer.swift
//  AhmedAmin-Assignment
//
//  Created by Amin  on 7/1/21.
//  Copyright © 2021 AhmedAmin. All rights reserved.
//

import Foundation
import CoreMotion


class Pedometer {
    
    // MARK: - Properties
    private let pedometer = CMPedometer()
    private let activityManager = CMMotionActivityManager()
    private var endDate: Date?
    private var startDate: Date?
    private let date = Date()
    
    
    
    // MARK: - Init
    init(startDate: Date? = nil, endDate: Date? = nil) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    
    
    
    
    // MARK: - Methods
    func setupActivityManager() {
        if CMMotionActivityManager.isActivityAvailable() && CMPedometer.authorizationStatus() == .authorized && CMPedometer.isStepCountingAvailable() {
            startTrackingActivityType()
        } else {
            print("cout steps is not available on your device")
        }
    }
    
    
    func countingSteps() {
        pedometer.startUpdates(from: date) { [weak self] (data, errors) in
            guard let self = self else { return }
            
            // Handle Error during Walking
            if let error = errors {
                print("there is error while counting the steps \(error.localizedDescription)!")
                return
            }
            
            guard let data = data else { return }
            
            // counting steps
            self.handlesSteps(data)
        }
    }
    
    // Handle Number of steps
    func handlesSteps(_ data: CMPedometerData) {
        
        // If User Stop 5 min
        if endDate?.advanced(by: TimeInterval(300)) ?? date > startDate ?? date {
            TripCashing.trips.append(Trip(numberOfSteps: data.numberOfSteps))
        }
    }
    
    // Indicate if the user stationary or walking
    func startTrackingActivityType() {
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let self = self else { return }
            guard let activity = activity else { return }
            
            if activity.stationary {
                
                self.pedometer.stopUpdates()
                self.endDate = activity.startDate
                
            } else if activity.walking {
                
                self.countingSteps()
                self.startDate = activity.startDate
            }
        }
    }
}

