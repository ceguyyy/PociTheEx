
import SwiftUI

struct GroundView: View {
    @State private var groundPosX = 90.0
    @Binding var pocisState : pociStateModel
    
    var body: some View {
        
            ZStack{
                Image("way")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 2900)
                    .offset(x: groundPosX)
                    .opacity(pocisState != .gameOver ? 1 : 0)
                Image("way")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 2900)
                    .offset(x: 29)
                    
                .opacity(pocisState != .gameOver ? 0 : 1)
            }
            .frame(width: 430)
            .clipped()
            .onAppear{
                withAnimation(.linear(duration: 12.9).repeatForever(autoreverses: false)){
                    groundPosX = -90
                }
            }
    }
}

struct GroundView_Previews: PreviewProvider {
    static var previews: some View {
        GroundView(pocisState: .constant(.walk))
    }
}
