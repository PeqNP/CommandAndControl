/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

struct IgnoreError: Error { }

typealias QueueableFuture = Future<Void, IgnoreError>
typealias JobFinishedCallback = () -> ()

class EventQueue {
    typealias SyncCallback = () -> ()
    typealias AsyncCallback = (@escaping JobFinishedCallback) -> ()
    typealias FutureCallback = () -> QueueableFuture?
    
    private var queue: [Any] = [Any]()
    
    func add(_ callback: SyncCallback) -> EventQueue {
        queue.append(callback)
        return self
    }
    
    func add(_ callback: FutureCallback) -> EventQueue {
        queue.append(callback)
        return self
    }
    
    func add(_ callback: AsyncCallback) -> EventQueue {
        queue.append(callback)
        return self
    }
    
    func execute() {
        while queue.count > 0 {
            let nextCallback = queue.removeFirst()
            
            if let callback = nextCallback as? SyncCallback {
                callback()
            }
            else if let callback = nextCallback as? FutureCallback, let future = callback() {
                future.onComplete { [weak self] _ in
                    self?.execute()
                }
                break
            }
            else if let callback = nextCallback as? AsyncCallback {
                callback { [weak self] in
                    self?.execute()
                }
                break
            }
        }
    }
}

extension Future {
    
    func makeQueueable() -> QueueableFuture {
        return self.map { _ -> Void in
            return Void()
            }
            .mapError { _ -> IgnoreError in
                return IgnoreError()
        }
    }
}
