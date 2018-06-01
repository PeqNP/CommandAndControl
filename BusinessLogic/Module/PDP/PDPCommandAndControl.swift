/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum PDPCommand {
    case update(PDPViewState)
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
    
    private let queue: EventQueue = EventQueue()
    
    private let bagService: BagService
    private let shippingService: ShippingService
    private let businessLogic: PDPBusinessLogic
    private let factory: PDPViewStateFactory

    weak var delegate: PDPCommandAndControlDelegate?
    
    init(bagService: BagService, shippingService: ShippingService, businessLogic: PDPBusinessLogic, factory: PDPViewStateFactory) {
        self.bagService = bagService
        self.shippingService = shippingService
        self.businessLogic = businessLogic
        self.factory = factory
    }
    
    // MARK: - Public Methods
    
    func selectedSKUSize(_ size: SKUSize) {
        let state = businessLogic.selectSKUSize(size)
        update(with: state)
    }
    
    func selectedSKUColor(_ color: SKUColor) {
        let state = businessLogic.selectSKUColor(color)
        update(with: state)
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
        queue
            .add(showLoadingIndicator)
            .add(loadShippingInformation)
            .add(hideLoadingIndicator)
            .execute()
    }
    
    func amountChanged(_ amount: Int) {
        let state = businessLogic.updateAmountToPurchaseTo(amount)
        update(with: state)
    }
    
    func addToBagTapped() {
        queue
            .add(showLoadingIndicator)
            .add(addItemToBag)
            .add(hideLoadingIndicator)
            .execute()
    }
    
    // TODO: Add a feature where the `BusinessLogic` determines if the user should be routed.
    
    // MARK: - Private Methods
    
    private func showLoadingIndicator() {
        delegate?.command(.showLoadingIndicator)
    }
    
    private func hideLoadingIndicator() {
        delegate?.command(.hideLoadingIndicator)
    }

    private func loadShippingInformation() -> QueueableFuture? {
        return shippingService.shippingInformationFor(productID: businessLogic.productID)
            .onSuccess { [weak self] (shippingInfo) in
                self?.showShippingInfo(shippingInfo)
            }
            .onFailure { [weak self] (error) in
                self?.showError(error)
            }
            .makeQueueable()
    }
    
    private func addItemToBag() -> QueueableFuture? {
        guard let skuID = businessLogic.selectedSKUID else {
            return nil
        }
        startAddingSKUToBag()
        return bagService.addToBag(skuID: skuID)
            .onSuccess { [weak self] _ in
                self?.finishAddingSKUToBag()
            }
            .onFailure { [weak self] _ in
                self?.failedToAddSKUToBag()
            }
            .makeQueueable()
    }
    
    private func startAddingSKUToBag() {
        let state = businessLogic.addSKUToBag()
        update(with: state)
    }
    
    private func finishAddingSKUToBag() {
        let state = businessLogic.addedSKUToBag()
        update(with: state)
    }
    
    private func failedToAddSKUToBag() {
        let state = businessLogic.failedToAddSKUToBag()
        update(with: state)
    }
    
    private func showShippingInfo(_ shippingInfo: ShippingInfo) {
        let viewState = factory.makeShippingInfoViewStateFrom(shippingInfo: shippingInfo)
        delegate?.command(.showShippingInfo(viewState))
    }
    
    private func showError(_ error: Error) {
        delegate?.command(.showError(error))
    }
    
    private func update(with state: PDPBusinessLogicState) {
        switch state {
        case .success(let pdpState):
            let viewState = factory.makePDPViewStateFrom(state: pdpState)
            delegate?.command(.update(viewState))
        case .error(let error):
            delegate?.command(.showError(error))
        }
    }
}
