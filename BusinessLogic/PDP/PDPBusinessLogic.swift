/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

struct Product {
    let id: ProductID
    let name: String
    let price: NormalPrice
    let skus: [SKU]
}

struct SKUColor {
    let name: String
    let imageURL: URL?
}

struct SKUSize {
    let name: String
    let metaDescription: String
}

enum Price {
    case regular(Double)
    case sale(was: Double, now: Double)
}

enum NormalPrice {
    case single(Price)
    case range(from: Price, to: Price)
}

struct SKU {
    let id: SKUID
    let color: SKUColor
    let size: SKUSize
    let price: Price
}

enum OptionalSKU {
    case `nil`
    case set(SKU?)
    
    func value(from previous: SKU?) -> SKU? {
        switch self {
        case .nil:
            return previous
        case .set(let value):
            return value
        }
    }
}

enum OptionalSKUColor {
    case `nil`
    case set(SKUColor?)
    
    func value(from previous: SKUColor?) -> SKUColor? {
        switch self {
        case .nil:
            return previous
        case .set(let value):
            return value
        }
    }
}

enum OptionalSKUSize {
    case `nil`
    case set(SKUSize?)
    
    func value(from previous: SKUSize?) -> SKUSize? {
        switch self {
        case .nil:
            return previous
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
    
    func make(selectedColor: OptionalSKUColor = .nil, selectedSize: OptionalSKUSize = .nil, selectedSKU: OptionalSKU = .nil) -> PDPState {
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
