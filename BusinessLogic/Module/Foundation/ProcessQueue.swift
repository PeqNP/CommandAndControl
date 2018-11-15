import Foundation

typealias ProcessQueueCallback = () -> Void

protocol ProcessQueue {
    func asyncAfter(interval: TimeInterval, callback: @escaping ProcessQueueCallback)
}

extension DispatchQueue: ProcessQueue {
    func asyncAfter(interval: TimeInterval, callback: @escaping ProcessQueueCallback) {
        asyncAfter(deadline: DispatchTime.now() + interval, execute: callback)
    }
}
