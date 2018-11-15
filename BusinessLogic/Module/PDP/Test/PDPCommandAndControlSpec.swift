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

class PDPCommandAndControlSpec: QuickSpec {
    override func spec() {
        
        describe("Given a PDPCommandAndControl") {
            var subject: PDPCommandAndControl!
            var delegate: FakePDPCommandAndControlDelegate!
            var processQueue: FakeProcessQueue!
            var bagService: FakeBagService!
            var shippingService: FakeShippingService!
            var logic: FakePDPBusinessLogic!
            var logicFactory: FakePDPBusinessLogicFactory!
            var viewStateFactory: FakePDPViewStateFactory!
            
            let product = Product.testMake(id: 10, name: "Test")
            
            beforeEach {
                delegate = FakePDPCommandAndControlDelegate()
                processQueue = FakeProcessQueue()
                bagService = FakeBagService()
                shippingService = FakeShippingService()
                logic = FakePDPBusinessLogic()
                logicFactory = FakePDPBusinessLogicFactory()
                logicFactory.stub(.makeFromProduct).with(product).andReturn(logic)
                
                viewStateFactory = FakePDPViewStateFactory()
                
                subject = PDPCommandAndControl(processQueue: processQueue, bagService: bagService, shippingService: shippingService, logicFactory: logicFactory, viewStateFactory: viewStateFactory)
                subject.delegate = delegate
            }
            
            // MARK: Generic example showing how a view state is manufactured
            
            describe("select a SKU size") {
                let expectedSKUSize = SKUSize(name: "Large", metaDescription: nil)
                let expectedState = PDPViewState.testMake(productName: "Test")
                
                beforeEach {
                    delegate.stub(.command).andReturn()
                    logic.stub(.selectSKUSize).andReturn(PDPStateResult.testMake())
                    viewStateFactory.stub(.makePDPViewStateFrom).andReturn(expectedState)
                    
                    subject.receive(.configure(product))
                    subject.receive(.selectedSKUSize(expectedSKUSize))
                }
                
                it("should have made call to business logic") {
                    expect(logic).to(haveReceived(.selectSKUSize, with: expectedSKUSize))
                }
                
                it("should have returned the correct view state") {
                    expect(delegate).to(haveReceived(.command, with: PDPCommand.update(expectedState)))
                }
            }
            
            // MARK: Example showing how a service call can be tested
            
            describe("request shipping information") {
                var promise: Promise<ShippingInfo, ShippingServiceError>!
                
                beforeEach {
                    promise = Promise<ShippingInfo, ShippingServiceError>()
                    
                    logic.stub(.productID).andReturn(product.id)
                    delegate.stub(.command).andReturn()
                    shippingService.stub(.shippingInformationFor).with(product.id).andReturn(promise.future)
                    
                    subject.receive(.configure(product))
                    subject.receive(.requestedShippingInformation)
                }
                
                it("should have sent the correct commands") {
                    let expectedCommands: [PDPCommand] = [
                        .showLoadingIndicator,
                    ]
                    expect(delegate.commands).to(equal(expectedCommands))
                }
                
                context("when the call succeeds") {
                    beforeEach {
                        promise.success(ShippingInfo())
                    }
                    
                    it("should have sent the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .showShippingInfo(ShippingInfoViewState()),
                            .hideLoadingIndicator
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }
                }
                
                context("when the call fails") {
                    beforeEach {
                        promise.failure(ShippingServiceError.generic)
                    }
                    
                    it("should have sent the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .showError(ShippingServiceError.generic),
                            .hideLoadingIndicator
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }
                }
            }
            
            describe("add selected SKU to the bag; failure") {
                beforeEach {
                    delegate.stub(.command).andReturn()
                    
                    subject.receive(.configure(product))
                    logic.stub(.addSKUToBag).andReturn(PDPStateResult.error(.operationInProgress))
                    subject.receive(.addToBagTapped)
                }
                
                it("should display an error") {
                    let expectedCommands: [PDPCommand] = [
                        .showLoadingIndicator,
                        .showError(PDPBusinessLogicError.operationInProgress),
                        .hideLoadingIndicator
                    ]
                    expect(delegate.commands).toEventually(equal(expectedCommands))
                }
            }
            
            describe("add selected SKU to the bag; success") {
                var promise: Promise<IgnorableResult, BagServiceError>!
                
                // TODO: The call is made
                // Success
                // Failure
                // Checked updated states
                
                beforeEach {
                    delegate.stub(.command).andReturn()
                    subject.receive(.configure(product))

                    promise = Promise()
                    bagService.stub(.addToBag).andReturn(promise.future)
                    
                    logic.stub(.selectedSKUID).andReturn(SKUID(10))
                    logic.stub(.addSKUToBag).andReturn(PDPStateResult.testMake())
                    subject.receive(.addToBagTapped)
                }
                
                it("should have made a call to the `BagService`") {
                    expect(bagService).to(haveReceived(.addToBag, with: SKUID(10)))
                }
                
                it("should execute the correct commands") {
                    let expectedCommands: [PDPCommand] = [
                        .showLoadingIndicator
                    ]
                    expect(delegate.commands).toEventually(equal(expectedCommands))
                }
                
                context("when the request succeeds") {
                    var callback: ProcessQueueCallback?
                    let expectedViewState = PDPViewState.testMake(productName: "Test")
                    
                    beforeEach {
                        callback = nil
                        
                        let state = PDPState.testMake(productName: "Test")
                        let result: PDPStateResult = .success(state)
                        logic.stub(.addedSKUToBag).andReturn(result)
                        viewStateFactory.stub(.makePDPViewStateFrom).andReturn(expectedViewState)
                        processQueue.stub(.asyncAfter).andDo { (args) -> Any? in
                            callback = args[1] as? ProcessQueueCallback
                            return Void()
                        }
                        
                        promise.success(IgnorableResult())
                        promise.waitUntilCompleted()
                    }
                    
                    it("should have registered the callback") {
                        expect(callback).toNot(beNil())
                    }
                    
                    it("should reset the add to bag state in 2 seconds") {
                        expect(processQueue).to(haveReceived(.asyncAfter, with: TimeInterval(2.0), Argument.anything))
                    }
                    
                    it("should execute the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .update(expectedViewState),
                            .hideLoadingIndicator
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }

                    context("when the callback is made") {
                        let addViewState = PDPViewState.testMake(addToBagState: .add)

                        beforeEach {
                            let state = PDPState.testMake(addToBagState: .add)
                            let result: PDPStateResult = .success(state)
                            logic.stub(.resetAddSKUToBag).andReturn(result)
                           
                            viewStateFactory.resetStubs()
                            viewStateFactory.stub(.makePDPViewStateFrom).andReturn(addViewState)
                            
                            callback?()
                        }
                        
                        fit("should have reset the add to bag state") {
                            let expectedCommands: [PDPCommand] = [
                                .showLoadingIndicator,
                                .update(expectedViewState),
                                .hideLoadingIndicator,
                                .update(addViewState)
                            ]
                            expect(delegate.commands).toEventually(equal(expectedCommands))
                        }
                    }
                }
            }
        }
        
    }
}
