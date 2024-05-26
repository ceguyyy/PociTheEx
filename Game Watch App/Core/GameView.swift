import SwiftUI
import AVFoundation



struct GameView: View {
    var backgroundMusic: AVAudioPlayer?
    @State private var score = 0
    @State var getScore = 0
    @State var isGameStart: Bool = false
    @State var pociPosY = 0.0
    @State var pocisState: pociStateModel = .walk
    @State var colliderHit = false
    @State private var playLabelOpacity = 1.0
    @State private var stepCount: Double = 0
    @State private var heartRate: Double = 0
    @State private var canPlayGame = false
    @State private var crownValue = 0.0
    @State private var stepMinimum : Double = 3693
    @State private var heartRateMinimum : Double = 90
    @State private var remainingSteps: Double = 0
    @State private var remainingHeartRate: Double = 0
    let healthDataFetcher = HealthDataFetcher()
    
    var body: some View {
        
        ZStack {

            cantPlayDisplay.scaleEffect(2)
            if canPlayGame{
                CloudsView().offset(y: 114).opacity(1)
                playLabel
                GroundView(pocisState: $pocisState).offset(y: 160)
                ObstacleView(colliderHit: $colliderHit, isGameStart: $isGameStart, getScore: $getScore, pociPosY: $pociPosY, pociState: $pocisState).offset(y: 0)
                scoreLabel.offset(y: -58)
                
                pociView(pociPosY: $pociPosY, pociState: $pocisState, isGameStart: $isGameStart).offset(y: 42)
                replayButton.offset(y: -29)
                   
                
            }
            
        }
  
        .onAppear {
            fetchHealthData()
        }   
        .scaleEffect(0.54)}
    
    
    
    private var cantPlayDisplay: some View {
        if !canPlayGame{
            return AnyView(
            TabView{
                ZStack{
                    CloudsView().offset(y: 125).opacity(0.5)
                    cantPlayGameText
                }
                ZStack{
                    CloudsView().offset(y: 125).opacity(0.5)
                    heartRateText
                }
            }
            .edgesIgnoringSafeArea(.all)
            )
            
            
        }else{
            return AnyView(EmptyView())
        }
    }

    
    
    
    
    
    private var scoreLabel: some View {
        if canPlayGame{
            return AnyView(
                HStack {
                    VStack {
                        Text("Score \(String(format: "%.5d", getScore))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.lightGray))
                        Spacer()
                    }
                }
                    .frame(alignment: .topTrailing)
                    .padding()
                    .zIndex(1)
            )
        }else{
            return AnyView(EmptyView())
        }
    }
    
    
    
    private var replayButton: some View {
        VStack {
            Spacer()
            if pocisState == .gameOver {
                Button {
                    resetGame()
                } label: {
                    VStack {
                        Image("btn-play-again")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72)
                        Text("play again".uppercased())
                            .font(.title2)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }
                }
                .padding()
            }
        }
    }
    
    private func fetchHealthData() {
        healthDataFetcher.fetchTodaySteps { count in
            DispatchQueue.main.async {
                self.stepCount = count
                self.canPlayGame = stepCount > stepMinimum && heartRate > heartRateMinimum
            }
        }
        
        
        healthDataFetcher.observeLiveStepCountUpdate { liveCount in
            DispatchQueue.main.async {
                self.stepCount = liveCount
                self.canPlayGame = stepCount > stepMinimum && heartRate > heartRateMinimum
            }
        }
        
        healthDataFetcher.fetchHeartRateData { rate in
            DispatchQueue.main.async {
                self.heartRate = rate
                self.canPlayGame = stepCount > stepMinimum && heartRate > heartRateMinimum
            }
        }
        
        healthDataFetcher.observeLiveHeartRateUpdate { liveRate in
            DispatchQueue.main.async {
                self.heartRate = liveRate
                self.canPlayGame = stepCount > stepMinimum && heartRate > heartRateMinimum
            }
        }
    }
    
    
    private func resetGame() {
        pociPosY = -7
        pocisState = .walk
        colliderHit = false
        isGameStart = true
        score = 0
        getScore = 0
    }
    
    private var playLabel: some View {
        VStack {
            Text("Touch the Poci & Do The Tasks".uppercased())
            Text("to Play")
                .font(.title2)
                .foregroundColor(.gray)
                .fontWeight(.bold)
        }
        .opacity(playLabelOpacity)
        .onAppear {
            withAnimation(.spring().delay(3)) {
                playLabelOpacity = 0.1
            }
        }
    }
    
    
    private func calculateRemainingSteps() -> String {
        let remainingSteps = stepMinimum - stepCount
        return String(format: "%.0f", remainingSteps)
    }
    
    private func calculateRemainingHeartRate() -> String {
        let remainingHeartRate = heartRateMinimum - heartRate
        return String(format: "%.0f", remainingHeartRate)
    }
    
    private var cantPlayGameText: some View {
        
        ZStack{
            ProgressView(value: stepCount, total: stepMinimum)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(3.5).opacity(0.7).colorMultiply(.green)
            
            VStack {
                
                Text("\(calculateRemainingSteps())")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
               
                
                Text("Remaining Steps")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
              
                Text("To Play")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
            
                
                
               
            }
            Spacer()
        }
        
        
        
    }
    
    
    private var heartRateText: some View {
        
        
        ZStack{
            ProgressView(value: heartRate, total: heartRateMinimum)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(3.5).opacity(0.7).colorMultiply(.red)
            
            VStack {
                
                Text("\(calculateRemainingHeartRate())")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
               
                
                Text("Remaining Bpm")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
              
                Text("To Play")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
            
                
                
               
            }
            Spacer()
        }
    }
}





struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
