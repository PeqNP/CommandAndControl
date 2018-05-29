/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum PDPCommand {
    case updated(PDPViewState)
    case showMoreInfo
    case showImageGallery
    case routeToPDPFor(ProductID)
    
}

protocol PDPCommandAndControlDelegate: class {
    func command(_ action: PDPCommand)
}

class PDPCommandAndControl {
    
    let shippingService: ShippingService
    let businessLogic: PDPBusinessLogic
    let factory: PDPViewStateFactory
    weak var delegate: PDPCommandAndControlDelegate?
    
    init(shippingService: ShippingService, businessLogic: PDPBusinessLogic, factory: PDPViewStateFactory) {
        self.shippingService = shippingService
        self.businessLogic = businessLogic
        self.factory = factory
    }
    
    func selectedSKUSize(_ size: SKUSize) {
        let state = businessLogic.selectSKUSize(size)
        let viewState = factory.makeFromState(state)
        self.delegate?.command(.updated(viewState))
        
    }
    
    func selectedSKUColor(_ color: SKUColor) {
        let state = businessLogic.selectSKUColor(color)
        let viewState = factory.makeFromState(state)
        self.delegate?.command(.updated(viewState))
    }
    
    func tappedMoreInfoButton() {
        self.delegate?.command(.showMoreInfo)
    }
    
    func tappedCarouselImage() {
        self.delegate?.command(.showImageGallery)
    }
    
    func tappedRecommendedProduct(_ productID: ProductID) {
        self.delegate?.command(.routeToPDPFor(productID))
    }
    
    func requestedShippingInformation() {
        shippingService.shippingInformationFor(productID: businessLogic.productID)
    }
}
