/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation
import Spry

@testable import BusinessLogic

class FakeProcessQueue: ProcessQueue, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case asyncAfter = "asyncAfter(interval:callback:)"
    }
    
    func asyncAfter(interval: TimeInterval, callback: @escaping ProcessQueueCallback) {
        return spryify(arguments: interval, callback)
    }
}
