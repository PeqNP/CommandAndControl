import Foundation
import Spry

@testable import BusinessLogic

class FakePDPBusinessLogic: PDPBusinessLogic, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case productID = "productID"
        case addOneMoreToPurchase = "addOneMoreToPurchase()"
        case selectSKUSize = "selectSKUSize"
        case selectSKUColor = "selectSKUColor"
        case addSKUToBag = "addSKUToBag"
    }

    let _bagService: BagService
    var _state: PDPState? = nil
    var _product: Product? = nil
    
    init() {
        self._bagService = FakeBagService()
        super.init(bagService: _bagService, state: PDPState.testMake())
    }
    
    override var productID: ProductID {
        get {
            return stubbedValue()
        }
    }
    
    override init(bagService: BagService, state: PDPState) {
        self._bagService = bagService
        self._state = state
        super.init(bagService: bagService, state: state)
    }
    
    override init(bagService: BagService, product: Product) {
        self._bagService = bagService
        self._product = product
        super.init(bagService: bagService, product: product)
    }
    
    override func addOneMoreToPurchase() -> PDPBusinessLogicState {
        return spryify()
    }
    
    override func selectSKUSize(_ size: SKUSize) -> PDPBusinessLogicState {
        return spryify(arguments: size)
    }
    
    override func selectSKUColor(_ color: SKUColor) -> PDPBusinessLogicState {
        return spryify(arguments: color)
    }
    
    override func addSKUToBag(_ callback: @escaping PDPBusinessLogicStatusCallback) throws {
        return try spryifyThrows(arguments: callback)
    }
}
