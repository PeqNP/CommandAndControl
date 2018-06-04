import AutoEquatable
import Foundation
import Spry

@testable import BusinessLogic

extension AddToBagState: AutoEquatable { }
extension PDPState: AutoEquatable, SpryEquatable { }
extension PDPCommand: AutoEquatable, SpryEquatable { }

extension PDPBusinessLogicError: AutoEquatable { }
extension PDPBusinessLogicState: AutoEquatable { }

extension PDPState {
    
    public static func testMake(productID: ProductID = 0, productName: String = "", price: NormalPrice = .single(.regular(0.0)), skus: [SKU] = [SKU](), amountToAddToBag: Int = 0, addToBagState: AddToBagState = .add, selectedColor: SKUColor? = nil, selectedSize: SKUSize? = nil, selectedSKU: SKU? = nil) -> PDPState {
        return PDPState(productID: productID, productName: productName, price: price, skus: skus, amountToAddToBag: amountToAddToBag, addToBagState: addToBagState, selectedColor: selectedColor, selectedSize: selectedSize, selectedSKU: selectedSKU)
    }
}
