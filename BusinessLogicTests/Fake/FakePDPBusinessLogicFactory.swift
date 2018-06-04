import BrightFutures
import Foundation
import Spry

@testable import BusinessLogic

class FakePDPBusinessLogicFactory: PDPBusinessLogicFactory, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case makeWithProduct = "makeWithProduct"
    }
    
    init() {
        super.init(bagService: FakeBagService())
    }
    
    override func makeWithProduct(_ product: Product) -> PDPBusinessLogic {
        return spryify(arguments: product)
    }
}
