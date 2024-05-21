import SwiftUI



struct GameView: View {
    
    @State private var score = 0
    @State var getScore = 0
    @State var isGameStart: Bool = false
    @State var dinoPosY = 0.0
    @State var dinoState: pociStateModel = .walk
    @State var colliderHit = false
    @State private var playLabelOpacity = 1.0
    @State private var stepCount: Double = 0
    @State private var heartRate: Double = 0
    @State private var canPlayGame = false
    @State private var crownValue = 0.0
    @State private var stepMinimum : Double = 3000
    @State private var heartRateMinimum : Double = 90
    let healthDataFetcher = HealthDataFetcher()
    
    var body: some View {
        
        ZStack {
            
            CloudsView().offset(y: 114)
            GroundView(dinoState: $dinoState).offset(y: 160)
            ObstacleView(colliderHit: $colliderHit, isGameStart: $isGameStart, getScore: $getScore, pociPosY: $dinoPosY, pociState: $dinoState).offset(y: 0)
            scoreLabel.offset(y: -58)
           
            pociView(pociPosY: $dinoPosY, pociState: $dinoState, isGameStart: $isGameStart).offset(y: 42)
            replayButton.offset(y: -29)
            playLabel
            if !canPlayGame {
                
                Text("Your heart rate is not fast enough or step count is not high enough to play.")
                    .foregroundColor(.red)
                    .padding(50)
                    .offset(y: 150)
            }
            
        }
        .scaleEffect(0.54)
        .onAppear {
            fetchHealthData()
        }
        .disabled(!canPlayGame)
    }
    
    private var scoreLabel: some View {
        HStack {
            VStack {
                Text("Score \(String(format: "%.5d", getScore))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.lightGray))
                Text("HeartRate: \(String(format: "%.0f", heartRate))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.lightGray))
                
                Text("Steps: \( stepCount.formattedString())")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.lightGray))
                Spacer()
            }
        }
        .frame(alignment: .topTrailing)
        .padding()
        .zIndex(1)
    }
    
    private var replayButton: some View {
        VStack {
            Spacer()
            if dinoState == .gameOver {
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
        dinoPosY = -7
        dinoState = .walk
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
            withAnimation(.spring().delay(5)) {
                playLabelOpacity = 0.1
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
