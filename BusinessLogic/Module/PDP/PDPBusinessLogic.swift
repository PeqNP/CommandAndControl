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

struct PDPState {
    let productID: ProductID
    let productName: String
    let price: NormalPrice
    let skus: [SKU]
    
    let selectedColor: SKUColor?
    let selectedSize: SKUSize?
    let selectedSKU: SKU?
    
    func make(selectedColor: Mutable<SKUColor> = .nil, selectedSize: Mutable<SKUSize> = .nil, selectedSKU: Mutable<SKU> = .nil) -> PDPState {
        return PDPState(
            productID: self.productID,
            productName: self.productName,
            price: self.price,
            skus: self.skus,
            
            selectedColor: selectedColor.value(from: self.selectedColor),
            selectedSize: selectedSize.value(from: self.selectedSize),
            selectedSKU: selectedSKU.value(from: self.selectedSKU)
        )
    }
}

class PDPBusinessLogic {
    
    private var previousState: PDPState
    
    var productID: ProductID {
        return previousState.productID
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
            selectedColor: nil,
            selectedSize: nil,
            selectedSKU: nil
        )
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPState {
        let selectedSKU: SKU? = skuFor(color: color, size: previousState.selectedSize)
        self.previousState = previousState.make(selectedSKU: .set(selectedSKU))
        return previousState
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPState {
        let selectedSKU: SKU? = skuFor(color: previousState.selectedColor, size: size)
        self.previousState = previousState.make(selectedSKU: .set(selectedSKU))
        return previousState
    }
    
    private func skuFor(color: SKUColor?, size: SKUSize?) -> SKU? {
        return nil
    }
}
