
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
                        healthDataFetcher.fetchTodaySteps { count in
                            DispatchQueue.main.async {
                                self.stepCount = count
                            }
                        }
                        healthDataFetcher.observeLiveStepCountUpdate { liveCount in
                            DispatchQueue.main.async {
                                self.stepCount = liveCount
                            }
                        }

                        healthDataFetcher.fetchHeartRateData { rate in
                            DispatchQueue.main.async {
                                self.heartRate = rate
                            }
                        }
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
