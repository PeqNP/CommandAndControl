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
    
    private var previousState: PDPState
    
    var productID: ProductID {
        return previousState.productID
    }
    
    var selectedSKUID: SKUID? {
        return previousState.selectedSKU?.id
    }
    
    init(initialState: PDPState) {
        self.previousState = initialState
    }
    
    init(product: Product) {
        self.previousState = PDPState(
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
        return .success(previousState)
    }
    
    func addSKUToBag() -> PDPBusinessLogicState {
        return .success(previousState)
    }
    
    func addedSKUToBag() -> PDPBusinessLogicState {
        // Reset the amount to purchase to 1
        return .success(previousState)
    }
    
    func failedToAddSKUToBag() -> PDPBusinessLogicState {
        return .success(previousState)
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: color, size: previousState.selectedSize)
        self.previousState = previousState.make(selectedSKU: .set(selectedSKU))
        return .success(previousState)
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: previousState.selectedColor, size: size)
        self.previousState = previousState.make(selectedSKU: .set(selectedSKU))
        return .success(previousState)
    }
    
    private func skuFor(color: SKUColor?, size: SKUSize?) -> SKU? {
        return nil
    }
}
