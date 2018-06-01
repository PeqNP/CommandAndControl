/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

struct IgnoreError: Error { }

typealias QueueableFuture = Future<Void, IgnoreError>

class EventQueue {
    typealias SyncCallback = () -> ()
    typealias FutureCallback = () -> QueueableFuture?
    
    private var queue: [Any] = [Any]()
    
    func add(_ sync: SyncCallback) -> EventQueue {
        queue.append(sync)
        return self
    }
    
    func add(_ async: FutureCallback) -> EventQueue {
        queue.append(async)
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
