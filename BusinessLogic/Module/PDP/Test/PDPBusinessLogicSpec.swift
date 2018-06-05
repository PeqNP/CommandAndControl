/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation
import Quick
import Nimble
import Spry
import Spry_Nimble

@testable import BusinessLogic

class PDPBusinessLogicSpec: QuickSpec {
    override func spec() {
        
        describe("Given a PDPBusinessLogic") {
            var subject: PDPBusinessLogic!
            var bagService: FakeBagService!
            var product: Product!

            beforeEach {
                bagService = FakeBagService()
            }
        
            describe("default values") {
                beforeEach {
                    product = Product.testMake(id: 1)
                    subject = PDPBusinessLogic(bagService: bagService, product: product)
                }
                
                it("should return the correct ProductID") {
                    expect(subject.productID).to(equal(product.id))
                }
                
                it("should set the initial state correctly") {
                    let expectedState = PDPState(
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
                    expect(subject.state).to(equal(expectedState))
                }
            }
            
            // MARK: A generic example of how to test the state machine
            
            describe("increasing the amount to purchase") {
                var state: PDPBusinessLogicState!
                var expectedState: PDPBusinessLogicState!
                
                context("when adding one more within limit") {
                    beforeEach {
                        product = Product.testMake(id: 1)
                        subject = PDPBusinessLogic(bagService: bagService, product: product)
                        expectedState = .success(subject.state.make(amountToAddToBag: 2))
                        state = subject.addOneMoreToPurchase()
                    }
                    
                    it("should have added one more to the bag") {
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when adding one more than is allowed") {
                    beforeEach {
                        subject = PDPBusinessLogic(bagService: bagService, state: PDPState.testMake(amountToAddToBag: 99))
                        state = subject.addOneMoreToPurchase()
                    }
                    
                    it("should have added one more to the bag") {
                        expectedState = .error(.exceededAmountThatCanBeAddedToBag)
                        expect(state).to(equal(expectedState))
                    }
                }
            }
            
            // MARK: An example of how a service can be tested
            
            describe("adding a sku to the bag") {
                var status: PDPBusinessLogicStatus!
                var state: PDPBusinessLogicState!
                var expectedState: PDPBusinessLogicState!
                var expectedError: PDPBusinessLogicError?
                var promise: Promise<IgnorableResult, BagServiceError>!
                
                beforeEach {
                    expectedError = nil
                    promise = Promise<IgnorableResult, BagServiceError>()
                    
                    bagService.stub(.addToBag).with(SKUID(2)).andReturn(promise.future)
                    product = Product.testMake(id: 1, skus: [
                        SKU.testMake(id: 2, color: SKUColor.testMake(name: "Red"), size: SKUSize.testMake(name: "Large"))
                    ])
                    subject = PDPBusinessLogic(bagService: bagService, product: product)

                    _ = subject.selectSKUSize(SKUSize(name: "Large", metaDescription: nil))
                    _ = subject.selectSKUColor(SKUColor(name: "Red", imageURL: nil))
                }
                
                let subjectAction = {
                    do {
                        try subject.addSKUToBag { (statusArg, stateArg) in
                            status = statusArg
                            state = stateArg
                        }
                    } catch {
                        expectedError = error as? PDPBusinessLogicError
                    }
                }
                
                context("when the process starts") {
                    beforeEach {
                        expectedState = .success(subject.state.make(addToBagState: .adding))
                        subjectAction()
                    }
                    
                    it("should have returned the correct state and status") {
                        expect(status).to(equal(PDPBusinessLogicStatus.inProgress))
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when the process succeeds") {
                    beforeEach {
                        expectedState = .success(subject.state.make(addToBagState: .added))
                        promise.success(IgnorableResult())
                        subjectAction()
                        expect(promise.future.value).toEventuallyNot(beNil())
                    }
                    
                    it("should have returned the correct state and status") {
                        expect(status).to(equal(PDPBusinessLogicStatus.complete))
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when the process fails") {
                    beforeEach {
                        promise.failure(.generic)
                        subjectAction()
                        expect(promise.future.error).toEventuallyNot(beNil())
                    }
                    
                    it("should have returned the correct state and status") {
                        expect(status).to(equal(PDPBusinessLogicStatus.complete))
                        expect(state).to(equal(PDPBusinessLogicState.error(.failedToAddSKUToBag)))
                    }
                }

                context("when attempting to add to the bag more than once") {
                    beforeEach {
                        subjectAction()
                        subjectAction()
                    }
                    
                    it("should have returned the correct state and status") {
                        expect(expectedError).to(equal(PDPBusinessLogicError.operationInProgress))
                    }
                }
            }
        }
        
    }
}
