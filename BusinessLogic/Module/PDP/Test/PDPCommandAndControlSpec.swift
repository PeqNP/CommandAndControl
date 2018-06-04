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
            var shippingService: FakeShippingService!
            var logicFactory: FakePDPBusinessLogicFactory!
            var logic: FakePDPBusinessLogic!
            var viewStateFactory: FakePDPViewStateFactory!
            
            let product = Product.testMake(id: 10, name: "Test")
            
            beforeEach {
                delegate = FakePDPCommandAndControlDelegate()
                shippingService = FakeShippingService()
                logic = FakePDPBusinessLogic()
                logicFactory = FakePDPBusinessLogicFactory()
                
                logicFactory.stub(.makeWithProduct).with(product).andDo({ (args) -> Any? in
                    return logic
                })
                
                viewStateFactory = FakePDPViewStateFactory()
                
                subject = PDPCommandAndControl(shippingService: shippingService, businessLogicFactory: logicFactory, factory: viewStateFactory)
                subject.delegate = delegate
            }
            
            // MARK: Generic example showing how a view state is manufactured
            
            describe("select a SKU size") {
                let expectedSKUSize = SKUSize(name: "Large", metaDescription: nil)
                let expectedState = PDPViewState.testMake(productName: "Test")
                
                beforeEach {
                    delegate.stub(.command).andReturn()
                    logic.stub(.selectSKUSize).andReturn(PDPBusinessLogicState.testMake())
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
            
            // MARK: Example showing how a logic future is used
            
            describe("add SKU to the bag") {
                let expectedState = PDPState.testMake(productID: 10, productName: "Test")
                var callback: PDPBusinessLogicStatusCallback!
                
                // TODO: Add throwing case
                
                beforeEach {
                    logic.stub(.addSKUToBag).andDo({ (args) -> Any? in
                        guard let callbackArg = args[0] as? PDPBusinessLogicStatusCallback else {
                            return XCTFail("Did not call BusinessLogic.addSKUToBag")
                        }
                        callback = callbackArg
                        return Void()
                    })
                    delegate.stub(.command).andReturn()
                    viewStateFactory.stub(.makePDPViewStateFrom).with(expectedState).andReturn(PDPViewState.testMake(productName: "Test"))

                    subject.receive(.configure(product))
                    subject.receive(.addToBagTapped)
                }
                
                context("when the process begins") {
                    beforeEach {
                        callback(.inProgress, .success(expectedState))
                    }
                    
                    fit("should have sent the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .update(PDPViewState.testMake(productName: "Test"))
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }
                }
                
                context("when the process succeeds") {
                    beforeEach {
                        callback(.complete, .success(expectedState))
                    }
                    
                    it("should have sent the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .update(PDPViewState.testMake(productName: "Test")),
                            .hideLoadingIndicator
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }
                }
                
                context("when the process fails") {
                    beforeEach {
                        callback(.complete, .error(.failedToAddSKUToBag))
                    }
                    
                    it("should have sent the correct commands") {
                        let expectedCommands: [PDPCommand] = [
                            .showLoadingIndicator,
                            .showError(PDPBusinessLogicError.failedToAddSKUToBag),
                            .hideLoadingIndicator
                        ]
                        expect(delegate.commands).toEventually(equal(expectedCommands))
                    }
                }
            }
        }
        
    }
}
