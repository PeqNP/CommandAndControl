import AutoEquatable
import Foundation

@testable import BusinessLogic

extension PDPViewState: AutoEquatable { }

extension PDPViewState {
    
    public static func testMake(productName: String = "", amountToAddToBag: String = "", skuColors: [SKUColorViewState] = [], skuSizes: [SKUSizeViewState] = [], selectedSKUColor: SKUColorViewState? = nil, selectedSKUSize: SKUSizeViewState? = nil, selectedSKU: SKUViewState? = nil, addToBagState: AddToBagState = .add) -> PDPViewState {
        return PDPViewState(productName: productName, amountToAddToBag: amountToAddToBag, skuColors: skuColors, skuSizes: skuSizes, selectedSKUColor: selectedSKUColor, selectedSKUSize: selectedSKUSize, selectedSKU: selectedSKU, addToBagState: addToBagState)
    }
}
