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
            var logic: FakePDPBusinessLogic!
            var logicFactory: FakePDPBusinessLogicFactory!
            var viewStateFactory: FakePDPViewStateFactory!
            
            let product = Product.testMake(id: 10, name: "Test")
            
            beforeEach {
                delegate = FakePDPCommandAndControlDelegate()
                shippingService = FakeShippingService()
                logic = FakePDPBusinessLogic()
                logicFactory = FakePDPBusinessLogicFactory()
                logicFactory.stub(.makeFromProduct).with(product).andReturn(logic)
                
                viewStateFactory = FakePDPViewStateFactory()
                
                subject = PDPCommandAndControl(shippingService: shippingService, logicFactory: logicFactory, viewStateFactory: viewStateFactory)
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
            
            describe("add selected SKU to the bag") {
                let expectedState = PDPState.testMake(productID: 10, productName: "Test")
                
                // TODO: The call is made
                // Success
                // Failure
                // Checked updated states
                
                beforeEach {
                }
            }
        }
        
    }
}
