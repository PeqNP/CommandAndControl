import Foundation
import Spry

@testable import BusinessLogic

class FakePDPCommandAndControlDelegate: PDPCommandAndControlDelegate, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case command = "command"
    }
    
    var commands: [PDPCommand] = []
    
    func command(_ action: PDPCommand) {
        commands.append(action)
        return spryify(arguments: action)
    }
}
