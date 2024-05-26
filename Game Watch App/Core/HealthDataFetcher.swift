

import Foundation
import HealthKit

class HealthDataFetcher {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRates = HKObjectType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [steps,heartRates]) { success, error in
            completion(success)
        }
    }
    
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date().startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            let stepCount = sum.doubleValue(for: HKUnit.count())
            completion(stepCount)
        }
        
        healthStore.execute(query)
    }
    
    func observeLiveStepCountUpdate(completion: @escaping (Double) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                let observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { query, completionHandler, error in
                    self.fetchTodaySteps { stepCount in
                        completion(stepCount)
                    }
                    completionHandler()
                }
                self.healthStore.execute(observerQuery)
            } else {
                // Handle error
                print("Error enabling background delivery: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    func fetchHeartRateData(completion: @escaping (Double) -> Void) {
          guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
              completion(0)
              return
          }
          
          let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-60), end: Date(), options: .strictEndDate)
          let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
              guard let result = result, let average = result.averageQuantity() else {
                  completion(0)
                  return
              }
              let heartRate = average.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
              completion(heartRate)
          }
          
          healthStore.execute(query)
      }
    
    
    func observeLiveHeartRateUpdate(completion: @escaping (Double) -> Void) {
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
            healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
                if success {
                    let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { query, completionHandler, error in
                        self.fetchHeartRateData { heartRate in
                            completion(heartRate)
                        }
                        completionHandler()
                    }
                    self.healthStore.execute(observerQuery)
                } else {
    
                    print("Error enabling background delivery: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    
    
    
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension Double {
    func formattedString(decimalPlaces: Int = 0) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = decimalPlaces
        
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

