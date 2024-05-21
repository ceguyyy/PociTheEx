
import SwiftUI
import AVFoundation


struct pociView: View {
    @State private var PociCurrentImage = UIImage(named: "dino-idle")!
    @Binding var pociPosY: Double
    @State var dinoPosX = -129.0
    @Binding var pociState : pociStateModel
    let timer = Timer.publish(every: 0.0258, on: .main, in: .common).autoconnect()
    @State private var isJumping = false
    @State private var isFixPosX = false
    @Binding var isGameStart : Bool
    
    
    var body: some View {
            
        ZStack{
            PociImageView
                .offset(x: dinoPosX, y: pociPosY)
                .onAppear{
                    getPociState(state: pociState)

                }
                .onChange(of: pociState) { newDinoState in
                    getPociState(state: newDinoState)
                }
                .onTapGesture {
                   
                    if pociState == .walk {
                        getPociState(state: .jump)
                        isGameStart = true
                        
                    }
                    
                    
                }
        }
        .onReceive(timer) { _ in
            
            
            if pociState == .jump {
                
                if pociPosY > -92 && !isJumping{
                    pociPosY -= 14
        
                }
                else if pociPosY > -158 && !isJumping{
                    pociPosY -= 10
                    
                }
                else if pociPosY > -207 && !isJumping{
                    pociPosY -= 5
                  
                }
                
                else if pociPosY < -7 && isJumping{
                    pociPosY += 10
                    
                }
                
                
                
                if pociPosY <= -207 {
                    isJumping = true
                    isFixPosX = false
                }
                else if pociPosY >= -7 && isJumping {
                    isJumping = false
                    getPociState(state: .walk)
                }
            }
            else if pociState == .walk {
                if !isFixPosX {
                    isFixPosX.toggle()
                    
                }
            }
        }
    }
}
extension pociView{
    
    private var PociImageView: some View {

        Image(uiImage: PociCurrentImage)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 107)
    }

    func getPociState(state newPociState: pociStateModel){
        pociState = newPociState
        
        switch newPociState {
        case .walk:
            PociCurrentImage = UIImage(named: "\(pociState.imageName)left")!
            
        case .jump:
            PociCurrentImage = UIImage(named: newPociState.imageName)!
        default:
            PociCurrentImage = UIImage(named: newPociState.imageName)!
        }
    }
    
}
struct DinoView_Previews: PreviewProvider {
    static var previews: some View {
        pociView(pociPosY: .constant(0), pociState: .constant(.walk), isGameStart: .constant(false))
    }
}
