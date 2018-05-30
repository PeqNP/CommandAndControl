/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum PDPCommand {
    case updated(PDPViewState)
    case showLoadingIndicator
    case hideLoadingIndicator
    case showShippingInfo(ShippingInfoViewState)
    case showMoreInfo
    case showImageGallery
    case routeToPDPFor(ProductID)
    case showError(Error)
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
        let viewState = factory.makePDPViewStateFrom(state: state)
        delegate?.command(.updated(viewState))
        
    }
    
    func selectedSKUColor(_ color: SKUColor) {
        let state = businessLogic.selectSKUColor(color)
        let viewState = factory.makePDPViewStateFrom(state: state)
        delegate?.command(.updated(viewState))
    }
    
    func tappedMoreInfoButton() {
        delegate?.command(.showMoreInfo)
    }
    
    func tappedCarouselImage() {
        delegate?.command(.showImageGallery)
    }
    
    func tappedRecommendedProduct(_ productID: ProductID) {
        delegate?.command(.routeToPDPFor(productID))
    }
    
    func requestedShippingInformation() {
        delegate?.command(.showLoadingIndicator)
        shippingService.shippingInformationFor(productID: businessLogic.productID)
            .onSuccess { [weak self] (shippingInfo) in
                guard let strongSelf = self else {
                    return
                }
                let viewState = strongSelf.factory.makeShippingInfoViewStateFrom(shippingInfo: shippingInfo)
                strongSelf.delegate?.command(.showShippingInfo(viewState))
            }
            .onFailure { [weak self] (error) in
                self?.delegate?.command(.showError(error))
            }
            .onComplete { [weak self] _ in
                self?.delegate?.command(.hideLoadingIndicator)
            }
    }
}
