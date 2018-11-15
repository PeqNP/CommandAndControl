/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

struct SKUColorViewState {
    
}
struct SKUSizeViewState {
    
}
struct SKUViewState {
    
}

struct PDPViewState {
    let productName: String
    let amountToAddToBag: String
    let skuColors: [SKUColorViewState]
    let skuSizes: [SKUSizeViewState]
    let selectedSKUColor: SKUColorViewState?
    let selectedSKUSize: SKUSizeViewState?
    let selectedSKU: SKUViewState?
    let addToBagState: AddToBagState
}

struct ShippingInfoViewState {
    
}

class PDPViewStateFactory {
    
    func makePDPViewStateFrom(state: PDPState) -> PDPViewState {
        return PDPViewState(
            productName: state.productName,
            amountToAddToBag: String(state.amountToAddToBag),
            skuColors: [],
            skuSizes: [],
            selectedSKUColor: nil,
            selectedSKUSize: nil,
            selectedSKU: nil,
            addToBagState: state.addToBagState
        )
    }
    
    func makeShippingInfoViewStateFrom(shippingInfo: ShippingInfo) -> ShippingInfoViewState {
        return ShippingInfoViewState()
    }
}
