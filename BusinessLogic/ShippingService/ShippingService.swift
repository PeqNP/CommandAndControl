/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum ShippingServiceError: Error {
    case generic
}

struct ShippingInfo {
    
}

class ShippingService {
    
    func shippingInformationFor(productID: ProductID) -> Future<ShippingInfo, ShippingServiceError> {
        return Future(error: .generic)
    }
}
