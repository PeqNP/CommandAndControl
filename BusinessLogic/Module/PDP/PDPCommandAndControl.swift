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

enum PDPEvent {
    case configure(Product)
    case viewDidLoad
    case selectedSKUSize(SKUSize)
    case selectedSKUColor(SKUColor)
    case tappedMoreInfoButton
    case tappedCarouselImage
    case tappedRecommendedProduct(ProductID)
    case requestedShippingInformation
    case amountChanged(Int)
    case addToBagTapped
}

protocol PDPCommandAndControlDelegate: class {
    func command(_ action: PDPCommand)
}

class PDPCommandAndControl {
    
    private let queue: EventQueue = EventQueue()
    private var businessLogic: PDPBusinessLogic!

    private let shippingService: ShippingService
    private let businessLogicFactory: PDPBusinessLogicFactory
    private let factory: PDPViewStateFactory

    weak var delegate: PDPCommandAndControlDelegate?
    
    init(shippingService: ShippingService, businessLogicFactory: PDPBusinessLogicFactory, factory: PDPViewStateFactory) {
        self.shippingService = shippingService
        self.businessLogicFactory = businessLogicFactory
        self.factory = factory
    }
    
    // MARK: - Internal Methods
    
    func receive(_ event: PDPEvent) {
        switch event {
        case .configure(let product):
            businessLogic = businessLogicFactory.makeWithProduct(product)
        case .viewDidLoad:
            break
        case .selectedSKUSize(let size):
            selectedSKUSize(size)
        case .selectedSKUColor(let color):
            selectedSKUColor(color)
        case .tappedMoreInfoButton:
            tappedMoreInfoButton()
        case .tappedCarouselImage:
            tappedCarouselImage()
        case .tappedRecommendedProduct(let productID):
            tappedRecommendedProduct(productID)
        case .requestedShippingInformation:
            requestedShippingInformation()
        case .amountChanged(let amount):
            amountChanged(amount)
        case .addToBagTapped:
            addToBagTapped()
        }
    }
    
    // MARK: - Private Methods

    // MARK: Events
    
    private func selectedSKUSize(_ size: SKUSize) {
        let state = businessLogic.selectSKUSize(size)
        update(with: state)
    }
    
    private func selectedSKUColor(_ color: SKUColor) {
        let state = businessLogic.selectSKUColor(color)
        update(with: state)
    }
    
    private func tappedMoreInfoButton() {
        delegate?.command(.showMoreInfo)
    }
    
    private func tappedCarouselImage() {
        delegate?.command(.showImageGallery)
    }
    
    private func tappedRecommendedProduct(_ productID: ProductID) {
        delegate?.command(.routeToPDPFor(productID))
    }
    
    /**
     Request shipping information on-demand.
     
     This shows how you can chain several `PDPCommand`s together.
     */
    private func requestedShippingInformation() {
        queue
            .add(showLoadingIndicator)
            .add(loadShippingInformation)
            .add(hideLoadingIndicator)
            .execute()
    }
    
    private func amountChanged(_ amount: Int) {
        let state = businessLogic.updateAmountToPurchaseTo(amount)
        update(with: state)
    }
    
    /**
     Adds the selected SKU to the bag with the requested amount.
     
     This shows how you can chain several `PDPCommand`s together using a `EventQueue.JobFinishedCallback`.
     */
    private func addToBagTapped() {
        queue
            .add(addSKUToBag)
            .execute()
    }
    
    // MARK: Helpers
    
    // TODO: Add a feature where the `BusinessLogic` determines if the user should be routed.
    
    private func showLoadingIndicator() {
        delegate?.command(.showLoadingIndicator)
    }
    
    private func hideLoadingIndicator() {
        delegate?.command(.hideLoadingIndicator)
    }

    /**
     Load shipping information for a product on-demand.
 
     This method shows how an event unrelated to the main `PDPState` can be handled. You could potentially have a `ShippingInfoBusinessLogic` but that's unnecessary as the operation is so simple.
     */
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
    
    /**
     Add the selected SKU to the shopper's bag.
     
     This method shows how an asynchronous event can be handled by the `BusinessLogic` using a `EventQueue.JobFinishedCallback`.
     
     Some asynchronous events can only be executed one at a time. In this case the `BusinessLogic` throws an exception if `addSKUToBag` is called if a previous operation is still in progress.
     */
    private func addSKUToBag(_ callback: @escaping JobFinishedCallback) {
        do {
            try businessLogic.addSKUToBag { [weak self] (status, state) in
                self?.update(with: state)
                if case .complete = status {
                    callback()
                }
            }
        }
        catch {
            callback()
        }
    }
    
    private func showShippingInfo(_ shippingInfo: ShippingInfo) {
        let viewState = factory.makeShippingInfoViewStateFrom(shippingInfo: shippingInfo)
        delegate?.command(.showShippingInfo(viewState))
    }
    
    /**
     Show an error.
     
     The `Error` in this context is purposely generic as it can handle `Error`s from `Service`s, `BusinessLogic`, or any other dependency.
     */
    private func showError(_ error: Error) {
        delegate?.command(.showError(error))
    }
    
    private func update(with state: PDPBusinessLogicState) {
        switch state {
        case .success(let pdpState):
            let viewState = factory.makePDPViewStateFrom(state: pdpState)
            delegate?.command(.update(viewState))
        case .error(let error):
            showError(error)
        }
    }
}
