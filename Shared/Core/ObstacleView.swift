import SwiftUI
import WatchKit


struct ObstacleView : View {
    @State private var posX : Double = 0
    @State private var posXs : [Double] = [0.0, 0.0, 0.0, 0]
    @State private var maxX: Double = 500
    @State private var minX: Double = -500
    @State var speed: Double = 15.0
    let range = 92.0...192
    @State var changeIt = false
    @Binding var colliderHit: Bool
    @Binding var isGameStart : Bool
    @Binding var getScore : Int
    @Binding var pociPosY : Double
    @Binding var pociState : pociStateModel
    @State private var spawnSpeed: Double = 15.0
    @State private var timeElapsed: Double = 0.0
    @State private var initialTime: Date = Date()
    
    
    let timer = Timer.publish(every: 0.005, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[0], colliderHit: $colliderHit, getScore: $getScore, pociPosY: $pociPosY, pociState: $pociState)
                .position(x: posXs[0], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[1], colliderHit: $colliderHit, getScore: $getScore, pociPosY: $pociPosY, pociState: $pociState)
                .position(x: posXs[1], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[2], colliderHit: $colliderHit, getScore: $getScore, pociPosY: $pociPosY, pociState: $pociState)
                .position(x: posXs[2], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[3], colliderHit: $colliderHit, getScore: $getScore, pociPosY: $pociPosY, pociState: $pociState)
                .position(x: posXs[3], y: 96)
        }
        .onAppear {
            changeIt.toggle()
            posX = maxX
            posXs = [posX, posX + 258, posX + 592, posX + 900]
            initialTime = Date()
        }
        .onReceive(timer) { _ in
            
            if isGameStart && !colliderHit {
                let currentTime = Date()
                let elapsedTime = currentTime.timeIntervalSince(initialTime)
                
                posX -= 1
                posXs = [posX, posX + 258, posX + 592, posX + 900]
                
                if posX < -990 {
                    posX = maxX
                }
                
                if elapsedTime >= 10.0 {
                    spawnSpeed -= 0.2
                    initialTime = currentTime
                }
            }
        }
        .onChange(of: colliderHit) { newValue in
            if !newValue {
                posX = maxX
                posXs = [posX, posX + 258, posX + 592, posX + 900]
                spawnSpeed = 15.0
                initialTime = Date()
            }
        }
        .frame(width: 430, height: 192)
        .clipped()
    }
}

private struct ObstaclePrefab: View {
    @Binding var changeIt : Bool
    @Binding var posX : Double
    @Binding var colliderHit : Bool
    @Binding var getScore : Int
    @Binding var pociPosY : Double
    @Binding var pociState : pociStateModel
    let obstacleList =  ObstacleModel.allCases
    @State private var image = ""
    
    var body: some View {
        HStack(alignment: .bottom){
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 72,height: 72)
            ZStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 29,height: 192)
                Text("\(String(format: "%.0f",posX))\n\(String(format: "%.0f",pociPosY))")
                    .opacity(0)
            }
        }
        .onChange(of: changeIt, perform: { _ in
            image = obstacleList[obstacleList.indices.randomElement()!].imageName
        })
        .onChange(of: posX) { newPosX in
          
            if pociPosY > -40 && posX > 129 && posX < 140 {
                colliderHit = true
                WKInterfaceDevice.current().play(.failure)
                pociState = .gameOver
            }
            if !colliderHit && posX == 29 {
                
                let getRandomScore = Int.random(in: 7..<10)
                withAnimation(.spring()){
                    getScore += getRandomScore
                }
               
            }
            
        }
    }
    
}

struct ObstacleView_Previews: PreviewProvider {
    static var previews: some View {
        ObstacleView( colliderHit: .constant(false), isGameStart: .constant(true), getScore: .constant(0), pociPosY: .constant(-40), pociState: .constant(.walk)).offset(x: 0, y: 0)
    }
}
