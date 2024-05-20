import SwiftUI



struct GameView: View {
    
    @State private var score = 0
    @State var getScore = 0
    @State var isGameStart: Bool = false
    @State var dinoPosY = 0.0
    @State var dinoState: DinoStateModel = .walk
    @State var colliderHit = false
    @State private var playLabelOpacity = 1.0
    @State private var stepCount: Double = 0
    @State private var heartRate: Double = 0
    @State private var canPlayGame = false
    @State private var crownValue = 0.0
    @State private var stepMinimum = 3000
    @State private var heartRateMinimum = 90
    
    let healthDataFetcher = HealthDataFetcher()
    
    var body: some View {
        
        ZStack {
            if !canPlayGame{
                
                Image(systemName: "lock.circle").font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/).foregroundColor(.red)
            }
            CloudsView().offset(y: 114)
            ObstacleView(colliderHit: $colliderHit, isGameStart: $isGameStart, getScore: $getScore, dinoPosY: $dinoPosY, dinoState: $dinoState).offset(y: 0)
            scoreLabel.offset(y: -58)
            GroundView(dinoState: $dinoState).offset(y: 72)
            DinoView(dinoPosY: $dinoPosY, dinoState: $dinoState, isGameStart: $isGameStart).offset(y: 42)
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
                    .foregroundColor(Color(.darkGray))
                Text("HeartRate: \(String(format: "%.0f", heartRate))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.darkGray))
                
                Text("Steps: \( stepCount.formattedString())")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.darkGray))
                
            }
        }
        .frame(maxWidth: 350, maxHeight: .infinity, alignment: .topTrailing)
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
                self.canPlayGame = stepCount > 1000 && heartRate > 90
            }
        }
        
        healthDataFetcher.observeLiveStepCountUpdate { liveCount in
            DispatchQueue.main.async {
                self.stepCount = liveCount
                self.canPlayGame = stepCount > 1000 && heartRate > 90
            }
        }
        
        healthDataFetcher.fetchHeartRateData { rate in
            DispatchQueue.main.async {
                self.heartRate = rate
                self.canPlayGame = stepCount > 1000 && heartRate > 90
            }
        }
        
        healthDataFetcher.observeLiveHeartRateUpdate { liveRate in
            DispatchQueue.main.async {
                self.heartRate = liveRate
                self.canPlayGame = stepCount > 1000 && heartRate > 90
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
                playLabelOpacity = 0.0
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
