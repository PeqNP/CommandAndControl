import BrightFutures
import Foundation
import Spry

@testable import BusinessLogic

class FakeShippingService: ShippingService, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case shippingInformationFor = "shippingInformationFor(productID:)"
    }
    
    override func shippingInformationFor(productID: ProductID) -> Future<ShippingInfo, ShippingServiceError> {
        return spryify(arguments: productID)
    }
}
