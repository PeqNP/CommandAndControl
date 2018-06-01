/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum Mutable<T> {
    case `nil`
    case set(T?)
    
    func value(from current: T?) -> T? {
        switch self {
        case .nil:
            return current
        case .set(let value):
            return value
        }
    }
}
