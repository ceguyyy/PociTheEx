//
//  ObstacleView.swift
//  NoInternetGoogleGameSwiftUI
//
//  Created by Baris OZGEN on 24.01.2023.
//
import SwiftUI
struct ObstacleView : View {
    @State private var posX : Double = 0
    @State private var posXs : [Double] = [0.0,0.0,0.0,0]
    @State private var maxX: Double = 500
    @State private var minX: Double = -500
    @State var speed: Double = 15.0
    let range = 92.0...192
    @State var changeIt = false
    @Binding var colliderHit: Bool
    @Binding var isGameStart : Bool
    @Binding var getScore : Int
    @Binding var dinoPosY : Double
    @Binding var dinoState : DinoStateModel

    let timer = Timer.publish(every: 0.007, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack{
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[0], colliderHit: $colliderHit, getScore: $getScore, dinoPosY: $dinoPosY, dinoState: $dinoState)
                .position(x: posXs[0], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[1], colliderHit: $colliderHit, getScore: $getScore, dinoPosY: $dinoPosY, dinoState: $dinoState)
                .position(x: posXs[1], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[2], colliderHit: $colliderHit, getScore: $getScore, dinoPosY: $dinoPosY, dinoState: $dinoState)
                .position(x: posXs[2], y: 96)
            ObstaclePrefab(changeIt: $changeIt, posX: $posXs[3], colliderHit: $colliderHit, getScore: $getScore, dinoPosY: $dinoPosY, dinoState: $dinoState)
                .position(x: posXs[3], y: 96)
            
            /*Text("\(posXs[0])\n\(posXs[1])\n\(posXs[2])\n\(posXs[3])\n")*/
        }
        .onAppear{
            changeIt.toggle()
            posX = maxX
            posXs = [posX, posX+258, posX+592, posX+900]
        }
        .onReceive(timer) { _ in
            
            if isGameStart && !colliderHit {
                
                posX -= 1
                posXs = [posX, posX+258, posX+592, posX+900]
                
                if posX < -990 {
                    posX = maxX
                }
            }
        }
        .onChange(of: colliderHit, perform: { newValue in
            if newValue == false {
                posX = maxX
                posXs = [posX, posX+258, posX+592, posX+900]
            }
        })
        .frame(width: 430,height: 192)
        .clipped()
        //.background(.red)
        
    }
}

private struct ObstaclePrefab: View {
    @Binding var changeIt : Bool
    @Binding var posX : Double
    @Binding var colliderHit : Bool
    @Binding var getScore : Int
    @Binding var dinoPosY : Double
    @Binding var dinoState : DinoStateModel
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
                Text("\(String(format: "%.0f",posX))\n\(String(format: "%.0f",dinoPosY))")
                    .opacity(0)
                
                /*Rectangle().frame(width: 32, height: 107)
                    .offset(y: dinoPosY)*/
            }
        }
        //.background(.yellow)
        .onChange(of: changeIt, perform: { _ in
            image = obstacleList[obstacleList.indices.randomElement()!].imageName
        })
        .onChange(of: posX) { newPosX in
            if dinoPosY > -40 && posX > 129 && posX < 140 {
                colliderHit = true
                dinoState = .gameOver
            }
            if !colliderHit && posX == 29 {
                let getRandomScore = Int.random(in: 7..<29)
                withAnimation(.spring()){
                    getScore += getRandomScore
                }
            }
            
        }
    }
}
struct ObstacleView_Previews: PreviewProvider {
    static var previews: some View {
        ObstacleView( colliderHit: .constant(false), isGameStart: .constant(true), getScore: .constant(0), dinoPosY: .constant(-40), dinoState: .constant(.walk)).offset(x: 0, y: 0)
    }
}
