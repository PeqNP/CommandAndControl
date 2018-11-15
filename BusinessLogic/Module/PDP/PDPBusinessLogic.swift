/**
 This is the `BusinessLogic` unit or `StateMachine` used by the Product Page.
 
 The primary purpose of this class is to encapsulate all business logic related to the PDP. It does not know anything about loading indicators, how it's data will be presented to the end-user, or internationalization. In some cases it _may_ provide status updates for operations which require a call to a remote service. For all intents and purposes it is simply data.

 NOTES:
 
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

// MARK: - State Model

enum AddToBagState {
    case add
    case adding
    case added
}

class PDPBusinessLogicFactory {
    func makeFromProduct(_ product: Product) -> PDPBusinessLogic {
        return PDPState(
            productID: product.id,
            productName: product.name,
            price: product.price,
            skus: product.skus,
            amountToAddToBag: 0,
            addToBagState: .add,
            selectedColor: nil,
            selectedSize: nil,
            selectedSKU: nil
        )
    }
}

// MARK: - BusinessLogic

enum PDPBusinessLogicError: Error {
    case skuIsNotSelected
    case failedToAddSKUToBag
    case operationInProgress
    case exceededAmountThatCanBeAddedToBag
}

enum PDPStateResult {
    case success(PDPState)
    case error(PDPBusinessLogicError)
}

protocol PDPBusinessLogic {
    var state: PDPState { get }
    var productID: ProductID { get }
    var selectedSKUID: SKUID? { get }
    
    func addOneMoreToPurchase() -> PDPStateResult
    func removeOneFromPurchase() -> PDPStateResult
    func selectSKUSize(_ size: SKUSize) -> PDPStateResult
    func selectSKUColor(_ color: SKUColor) -> PDPStateResult
    func addSKUToBag() -> PDPStateResult
    func addingSKUToBag() -> PDPStateResult
    func addedSKUToBag() -> PDPStateResult
}

extension PDPState: PDPBusinessLogic {
    
    var state: PDPState {
        return self
    }
    
    var selectedSKUID: SKUID? {
        return selectedSKU?.id
    }
    
    func addOneMoreToPurchase() -> PDPStateResult {
        let amount = amountToAddToBag + 1
        guard amount < 100 else {
            return .error(.exceededAmountThatCanBeAddedToBag)
        }
        
        return .success(make(amountToAddToBag: amount))
    }
    
    func removeOneFromPurchase() -> PDPStateResult {
        let amount = amountToAddToBag - 1
        guard amount > 0 else {
            return .success(self)
        }
        
        return .success(make(amountToAddToBag: amount))
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPStateResult {
        let selectedSKU: SKU? = skuFor(color: selectedColor, size: size)
        return .success(make(selectedSize: .set(size), selectedSKU: .set(selectedSKU)))
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPStateResult {
        let selectedSKU: SKU? = skuFor(color: color, size: selectedSize)
        return .success(make(selectedColor: .set(color), selectedSKU: .set(selectedSKU)))
    }
    
    func addSKUToBag() -> PDPStateResult {
        return .success(make(addToBagState: .add))
    }
    
    func addingSKUToBag() -> PDPStateResult {
        guard .adding != addToBagState else {
            return .error(.operationInProgress)
        }
        guard selectedSKUID != nil else {
            return .error(.skuIsNotSelected)
        }
        
        return .success(make(addToBagState: .adding))
    }
    
    func addedSKUToBag() -> PDPStateResult {
        return .success(make(addToBagState: .added))
    }
    
    // MARK: - Private methods
    
    private func skuFor(color: SKUColor?, size: SKUSize?) -> SKU? {
        return skus.first(where: { (sku) -> Bool in
            return sku.color == color && sku.size == size
        })
    }
}
