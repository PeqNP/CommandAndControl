import AutoEquatable
import Foundation
import Spry

@testable import BusinessLogic

extension SKU: AutoEquatable, SpryEquatable { }
extension SKUSize: AutoEquatable, SpryEquatable { }
extension SKUColor: AutoEquatable, SpryEquatable { }

extension SKU {
    
    public static func testMake(id: SKUID = 0, color: SKUColor = SKUColor.testMake(), size: SKUSize = SKUSize.testMake(), price: Price = .regular(0.0)) -> SKU {
        return SKU(id: id, color: color, size: size, price: price)
    }
}

extension SKUSize {
    
    public static func testMake(name: String = "", metaDescription: String? = nil) -> SKUSize {
        return SKUSize(name: name, metaDescription: metaDescription)
    }
}

extension SKUColor {
    
    public static func testMake(name: String = "", imageURL: URL? = nil) -> SKUColor {
        return SKUColor(name: name, imageURL: imageURL)
    }
}
