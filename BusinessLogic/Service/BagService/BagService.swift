/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum BagServiceError: Error {
    case generic
}

class BagService {
    
    func addToBag(skuID: SKUID) -> Future<IgnorableResult, BagServiceError> {
        return Future(error: .generic)
    }
}
