/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum AddToBagState {
    case add
    case adding
    case failedToAdd
}

struct PDPState {
    let productID: ProductID
    let productName: String
    let price: NormalPrice
    let skus: [SKU]
    
    /**
     NOTES:
 
     - There could be a `BagType` which determines whether an item is to be added to the bag or added to the reserve list. This way the `Add to Bag` button can be used for both features. The `AddToBagState` enumerations could even have an associated String value which identifies the text to display to the user in each context. That or a new set of enumerations could be created. It just depends on what the business requires in each context.
     */
    
    // Mutable
    let addToBagState: AddToBagState
    let selectedColor: SKUColor?
    let selectedSize: SKUSize?
    let selectedSKU: SKU?
    let error: Error?
    
    func make(addToBagState: AddToBagState? = nil, selectedColor: Mutable<SKUColor> = .nil, selectedSize: Mutable<SKUSize> = .nil, selectedSKU: Mutable<SKU> = .nil, error: Mutable<Error> = .nil) -> PDPState {
        return PDPState(
            productID: self.productID,
            productName: self.productName,
            price: self.price,
            skus: self.skus,
            
            addToBagState: addToBagState ?? self.addToBagState,
            selectedColor: selectedColor.value(from: self.selectedColor),
            selectedSize: selectedSize.value(from: self.selectedSize),
            selectedSKU: selectedSKU.value(from: self.selectedSKU),
            error: error.value(from: self.error)
        )
    }
}

enum PDPBusinessLogicState {
    case success(PDPState)
    case error(Error)
}

class PDPBusinessLogic {
    
    private var currentState: PDPState
    
    var productID: ProductID {
        return currentState.productID
    }
    
    var selectedSKUID: SKUID? {
        return currentState.selectedSKU?.id
    }
    
    init(initialState: PDPState) {
        self.currentState = initialState
    }
    
    init(product: Product) {
        self.currentState = PDPState(
            productID: product.id,
            productName: product.name,
            price: product.price,
            skus: product.skus,
            addToBagState: .add,
            selectedColor: nil,
            selectedSize: nil,
            selectedSKU: nil,
            error: nil
        )
    }
    
    func updateAmountToPurchaseTo(_ amount: Int) -> PDPBusinessLogicState {
        // Check the amount adding 0-99, return amount that is allowed
        return .success(currentState)
    }
    
    func addSKUToBag() -> PDPBusinessLogicState {
        return .success(currentState)
    }
    
    func addedSKUToBag() -> PDPBusinessLogicState {
        // Reset the amount to purchase to 1
        return .success(currentState)
    }
    
    func failedToAddSKUToBag() -> PDPBusinessLogicState {
        return .success(currentState)
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: color, size: currentState.selectedSize)
        self.currentState = currentState.make(selectedSKU: .set(selectedSKU))
        return .success(currentState)
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: currentState.selectedColor, size: size)
        self.currentState = currentState.make(selectedSKU: .set(selectedSKU))
        return .success(currentState)
    }
    
    private func skuFor(color: SKUColor?, size: SKUSize?) -> SKU? {
        return nil
    }
}
