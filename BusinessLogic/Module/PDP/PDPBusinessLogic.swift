/**
 This is the `BusinessLogic` unit or `StateMachine` used by the Product Page.
 
 The primary purpose of this class is to encapsulate all business logic related to the PDP. It does not know anything about loading indicators, how it's data will be presented to the end-user, or internationalization. In some cases it _may_ provide status updates for operations which require a call to a remote service. For all intents and purposes it is simply data.

 NOTES:
 
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

// MARK: - State Model

enum AddToBagState {
    case add
    case adding
    case added
}

struct PDPState {
    let productID: ProductID
    let productName: String
    let price: NormalPrice
    let skus: [SKU]
    
    // Mutable
    let amountToAddToBag: Int
    let addToBagState: AddToBagState
    let selectedColor: SKUColor?
    let selectedSize: SKUSize?
    let selectedSKU: SKU?
    
    func make(amountToAddToBag: Int? = nil, addToBagState: AddToBagState? = nil, selectedColor: Mutable<SKUColor> = .nil, selectedSize: Mutable<SKUSize> = .nil, selectedSKU: Mutable<SKU> = .nil) -> PDPState {
        return PDPState(
            productID: self.productID,
            productName: self.productName,
            price: self.price,
            skus: self.skus,
            
            amountToAddToBag: amountToAddToBag ?? self.amountToAddToBag,
            addToBagState: addToBagState ?? self.addToBagState,
            selectedColor: selectedColor.value(from: self.selectedColor),
            selectedSize: selectedSize.value(from: self.selectedSize),
            selectedSKU: selectedSKU.value(from: self.selectedSKU)
        )
    }
}

// MARK: - BusinessLogic

enum PDPBusinessLogicError: Error {
    case skuIsNotSelected
    case failedToAddSKUToBag
    case operationInProgress
    case exceededAmountThatCanBeAddedToBag
}

// NOTE: Could be made generic
enum PDPBusinessLogicState {
    case success(PDPState)
    case error(PDPBusinessLogicError)
}

// NOTE: Could be made generic/abstract
enum PDPBusinessLogicStatus {
    case inProgress
    // The above case could also look something like this:
    // `case inProgress(amountComplete: Double)`
    case complete
}

// NOTE: Could be made generic
typealias PDPBusinessLogicStatusCallback = (PDPBusinessLogicStatus, PDPBusinessLogicState) -> ()

/**
 Manufactures `PDPBusinessLogic` with its respective dependencies.
 
 The `Product`/`PDPState` will not be known until run-time and, therefore, can not be provided at assembly time.
 */
class PDPBusinessLogicFactory {
    
    private let bagService: BagService
    
    init(bagService: BagService) {
        self.bagService = bagService
    }
    
    func makeWithProduct(_ product: Product) -> PDPBusinessLogic {
        return PDPBusinessLogic(bagService: bagService, product: product)
    }
    
    func makeWithState(_ state: PDPState) -> PDPBusinessLogic {
        return PDPBusinessLogic(bagService: bagService, state: state)
    }
}

class PDPBusinessLogic {
    
    var productID: ProductID {
        return state.productID
    }

    private var selectedSKUID: SKUID? {
        return state.selectedSKU?.id
    }

    private let bagService: BagService
    private(set) var state: PDPState
    
    init(bagService: BagService, product: Product) {
        self.bagService = bagService
        self.state = PDPState(
            productID: product.id,
            productName: product.name,
            price: product.price,
            skus: product.skus,
            amountToAddToBag: 1,
            addToBagState: .add,
            selectedColor: nil,
            selectedSize: nil,
            selectedSKU: nil
        )
    }
    
    init(bagService: BagService, state: PDPState) {
        self.bagService = bagService
        self.state = state
    }
    
    func addOneMoreToPurchase() -> PDPBusinessLogicState {
        let amount = state.amountToAddToBag + 1
        guard amount < 100 else {
            return .error(.exceededAmountThatCanBeAddedToBag)
        }
        
        state = state.make(amountToAddToBag: amount)
        return .success(state)
    }
    
    func removeOneFromPurchase() -> PDPBusinessLogicState {
        let amount = state.amountToAddToBag - 1
        guard amount > 0 else {
            return .success(state)
        }
        
        state = state.make(amountToAddToBag: amount)
        return .success(state)
    }
    
    func addSKUToBag(_ callback: @escaping PDPBusinessLogicStatusCallback) throws {
        guard .adding != state.addToBagState else {
            throw PDPBusinessLogicError.operationInProgress
        }
        guard let skuID = selectedSKUID else {
            return callback(.complete, .error(.skuIsNotSelected))
        }
        
        state = state.make(addToBagState: .adding)
        callback(.inProgress, .success(state))
        
        bagService.addToBag(skuID: skuID)
            .onSuccess { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.state = strongSelf.state.make(addToBagState: .added)
                callback(.complete, .success(strongSelf.state))
            }
            .onFailure { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.state = strongSelf.state.make(addToBagState: .add)
                callback(.inProgress, .success(strongSelf.state))
                callback(.complete, .error(.failedToAddSKUToBag))
            }
    }
    
    func selectSKUColor(_ color: SKUColor) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: color, size: state.selectedSize)
        self.state = state.make(selectedSKU: .set(selectedSKU))
        return .success(state)
    }
    
    func selectSKUSize(_ size: SKUSize) -> PDPBusinessLogicState {
        let selectedSKU: SKU? = skuFor(color: state.selectedColor, size: size)
        self.state = state.make(selectedSKU: .set(selectedSKU))
        return .success(state)
    }
    
    private func skuFor(color: SKUColor?, size: SKUSize?) -> SKU? {
        return nil
    }
}
