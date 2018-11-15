import Foundation
import Spry

@testable import BusinessLogic

class FakePDPBusinessLogicFactory: PDPBusinessLogicFactory, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case makeFromProduct = "makeFromProduct"
    }
    
    override func makeFromProduct(_ product: Product) -> PDPBusinessLogic {
        return spryify(arguments: product)
    }
}
