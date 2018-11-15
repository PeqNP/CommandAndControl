import Foundation
import Spry

@testable import BusinessLogic

class FakePDPBusinessLogic: PDPBusinessLogic, Spryable {
    
    enum ClassFunction: String, StringRepresentable {
        case empty
    }
    
    enum Function: String, StringRepresentable {
        case state = "state"
        case productID = "productID"
        case selectedSKUID = "selectedSKUID"
        case addOneMoreToPurchase = "addOneMoreToPurchase()"
        case removeOneFromPurchase = "removeOneFromPurchase()"
        case selectSKUSize = "selectSKUSize"
        case selectSKUColor = "selectSKUColor"
        case resetAddSKUToBag = "resetAddSKUToBag"
        case addSKUToBag = "addSKUToBag()"
        case addedSKUToBag = "addedSKUToBag()"
    }
    
    var state: PDPState {
        get {
            return stubbedValue()
        }
    }
    
    var selectedSKUID: SKUID? {
        get {
            return stubbedValue()
        }
    }
    
    var productID: ProductID {
        get {
            return stubbedValue()
        }
    }
    
    func addOneMoreToPurchase() -> PDPStateResult {
        return spryify()
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPStateResult {
        return spryify(arguments: size)
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPStateResult {
        return spryify(arguments: color)
    }
    
    func resetAddSKUToBag() -> PDPStateResult {
        return spryify()
    }
    
    func removeOneFromPurchase() -> PDPStateResult {
        return spryify()
    }
    
    func addSKUToBag() -> PDPStateResult {
        return spryify()
    }
    
    func addedSKUToBag() -> PDPStateResult {
        return spryify()
    }
}
