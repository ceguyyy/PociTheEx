import SwiftUI



struct GameView: View {
    
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
    let healthDataFetcher = HealthDataFetcher()
    
    var body: some View {
        
        ZStack {
            
            
            if !canPlayGame{
                CloudsView().offset(y: 114).opacity(0.3)
            }
            GroundView(pocisState: $pocisState).offset(y: 160)
            ObstacleView(colliderHit: $colliderHit, isGameStart: $isGameStart, getScore: $getScore, pociPosY: $pociPosY, pociState: $pocisState).offset(y: 0)
            scoreLabel.offset(y: -58)
           
            pociView(pociPosY: $pociPosY, pociState: $pocisState, isGameStart: $isGameStart).offset(y: 42)
            replayButton.offset(y: -29)
         
            
            
            
            if canPlayGame {
                playLabel
            }
            
            if !canPlayGame {
            cantPlayGameText
            }
            
        }
        .scaleEffect(0.54)
        .onAppear {
            fetchHealthData()
        }
        .disabled(!canPlayGame)
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
    
    private var cantPlayGameText: some View {
        HStack {
            VStack {
                Text("\(calculateRemainingSteps())").font(.largeTitle) .fontWeight(.bold)
                    .foregroundColor(Color(.lightGray))
                Text("Remaining Steps To Play ")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(Color(.lightGray))
                Spacer()
            }
        }
        .frame(alignment: .topTrailing)
        .padding()
        .zIndex(1)
    }

}




struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
