/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import AutoEquatable
import Foundation
import Spry

@testable import BusinessLogic

extension Product: AutoEquatable, SpryEquatable { }

extension Product {
    
    public static func testMake(id: ProductID = 0, name: String = "", price: NormalPrice = .single(.regular(0.0)), skus: [SKU] = [SKU]()) -> Product {
        return Product(id: id, name: name, price: price, skus: skus)
    }
}
