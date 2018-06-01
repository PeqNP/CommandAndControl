/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation
import Spry

@testable import BusinessLogic

class FakeBagService: BagService, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case addToBag = "addToBag(skuID:)"
    }
    
    override func addToBag(skuID: SKUID) -> Future<IgnorableResult, BagServiceError> {
        return spryify(arguments: skuID)
    }
}
