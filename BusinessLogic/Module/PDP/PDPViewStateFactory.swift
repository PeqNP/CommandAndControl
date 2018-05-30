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
    let skuColors: [SKUColorViewState]
    let skuSizes: [SKUSizeViewState]
    let selectedSKUColor: SKUColorViewState?
    let selectedSKUSize: SKUSizeViewState?
    let selectedSKU: SKUViewState?
}

struct ShippingInfoViewState {
    
}

class PDPViewStateFactory {
    
    func makePDPViewStateFrom(state: PDPState) -> PDPViewState {
        return PDPViewState(
            productName: state.productName,
            skuColors: [],
            skuSizes: [],
            selectedSKUColor: nil,
            selectedSKUSize: nil,
            selectedSKU: nil
        )
    }
    
    func makeShippingInfoViewStateFrom(shippingInfo: ShippingInfo) -> ShippingInfoViewState {
        return ShippingInfoViewState()
    }
}
