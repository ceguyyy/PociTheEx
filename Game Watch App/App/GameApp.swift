
import SwiftUI

@main
struct Game_Watch_AppApp: App {
    
    @State private var stepCount: Double = 0
    @State private var heartRate: Double = 0
    let healthDataFetcher = HealthDataFetcher()
    @State private var isAuthorized: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthorized {
                GameView()
                
                    .onAppear {
                        // Fetch and display step count
                        healthDataFetcher.fetchTodaySteps { count in
                            DispatchQueue.main.async {
                                self.stepCount = count
                            }
                        }
                        // Start observing live step count updates
                        healthDataFetcher.observeLiveStepCountUpdate { liveCount in
                            DispatchQueue.main.async {
                                self.stepCount = liveCount
                            }
                        }
                        
                        // Fetch and display heart rate
                        healthDataFetcher.fetchHeartRateData { rate in
                            DispatchQueue.main.async {
                                self.heartRate = rate
                            }
                        }
                        // Start observing live heart rate updates
                        healthDataFetcher.observeLiveHeartRateUpdate { liveRate in
                            DispatchQueue.main.async {
                                self.heartRate = liveRate
                            }
                        }
                    }
            } else {
                Text("Requesting Authorization...")
                    .onAppear {
                        healthDataFetcher.requestAuthorization { success in
                            if success {
                                self.isAuthorized = true
                            } else {
                                print("Authorization failed")
                            }
                        }
                    }
            }
        }
    }
}
