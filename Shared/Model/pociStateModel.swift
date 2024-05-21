
import Foundation

enum pociStateModel : Int, CaseIterable, Identifiable {
    case idle
    case walk
    case gameOver
    case jump
    
    var id : Int { return rawValue}
    
    var imageName : String {
        switch self {
            
        case .idle:
            return "dino-idle"
        case .walk:
            return "dino-walk-"
        case .gameOver:
            return "dino-idle-fail"
        case .jump:
            return "dino-idle"//"dino-idle-noeye"
        }
    }
}
