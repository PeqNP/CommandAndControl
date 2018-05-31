/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
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
    
    private let queue: EventQueue = EventQueue()
    
    private let bagService: BagService
    private let shippingService: ShippingService
    private let businessLogic: PDPBusinessLogic
    private let factory: PDPViewStateFactory

    weak var delegate: PDPCommandAndControlDelegate?
    
    init(bagService: BagService, shippingService: ShippingService, businessLogic: PDPBusinessLogic, factory: PDPViewStateFactory) {
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
        queue
            .add(showLoadingIndicator)
            .add(loadShippingInformation)
            .add(hideLoadingIndicator)
            .execute()
    }
    
    func addToBag() {
        queue
            .add(showLoadingIndicator)
            .add(addItemToBag)
            .add(hideLoadingIndicator)
            .execute()
    }
    
    // MARK: - Actions
    
    func showLoadingIndicator() {
        delegate?.command(.showLoadingIndicator)
    }
    
    func hideLoadingIndicator() {
        delegate?.command(.hideLoadingIndicator)
    }

    func loadShippingInformation() -> QueueableFuture? {
        return shippingService.shippingInformationFor(productID: businessLogic.productID)
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
            .makeQueueable()
    }
    
    func addItemToBag() -> QueueableFuture? {
        guard let skuID = businessLogic.selectedSKUID else {
            return nil
        }
        let state = businessLogic.addSKUToBag()
        let viewState = factory.makePDPViewStateFrom(state: state)
        delegate?.command(.updated(viewState))
        return bagService.addToBag(skuID: skuID)
            .onSuccess { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                let state = strongSelf.businessLogic.addedSKUToBag()
                let viewState = strongSelf.factory.makePDPViewStateFrom(state: state)
                strongSelf.delegate?.command(.updated(viewState))
            }
            .makeQueueable()
    }
}

struct IgnoreError: Error { }

typealias QueueableFuture = Future<Void, IgnoreError>

class EventQueue {
    typealias SyncCallback = () -> ()
    typealias FutureCallback = () -> QueueableFuture?
    
    private var queue: [Any] = [Any]()
    
    func add(_ sync: SyncCallback) -> EventQueue {
        queue.append(sync)
        return self
    }
    
    func add(_ async: FutureCallback) -> EventQueue {
        queue.append(async)
        return self
    }
    
    func execute() {
        while queue.count > 0 {
            let nextCallback = queue.removeFirst()
            
            if let callback = nextCallback as? SyncCallback {
                callback()
            }
            else if let callback = nextCallback as? FutureCallback {
                callback()?.onComplete { [weak self] _ in
                    self?.execute()
                }
                break
            }
        }
    }
}

extension Future {
    
    func makeQueueable() -> QueueableFuture {
        return self.map { _ -> Void in
            return Void()
        }
        .mapError { _ -> IgnoreError in
            return IgnoreError()
        }
    }
}
