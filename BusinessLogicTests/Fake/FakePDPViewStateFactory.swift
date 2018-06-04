import Foundation
import Spry

@testable import BusinessLogic

class FakePDPViewStateFactory: PDPViewStateFactory, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case makePDPViewStateFrom = "makePDPViewStateFrom(state:)"
    }
    
    override func makePDPViewStateFrom(state: PDPState) -> PDPViewState {
        return spryify(arguments: state)
    }
}
