
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
            return "poci-idle"
        case .walk:
            return "poci-walk-"
        case .gameOver:
            return "poci-idle-fail"
        case .jump:
            return "poci-idle"
        }
    }
}
