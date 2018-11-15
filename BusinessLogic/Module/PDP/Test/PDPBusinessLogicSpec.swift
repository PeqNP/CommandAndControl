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
            var subject: PDPState!
            var factory: PDPBusinessLogicFactory!

            var state: PDPStateResult!

            beforeEach {
                factory = PDPBusinessLogicFactory()
            }
            
            describe("initializing") {
                
                var product: Product!

                beforeEach {
                    product = Product.testMake(id: 1, name: "Shoes" /* TODO: price, skus */)
                    subject = factory.makeFromProduct(product).state
                }
                
                it("should have set the default values") {
                    expect(subject.productID).to(equal(product.id))
                    expect(subject.productName).to(equal(product.name))
                    expect(subject.price).to(equal(product.price))
                    expect(subject.skus).to(equal(product.skus))
                    
                    expect(subject.amountToAddToBag).to(equal(0))
                    expect(subject.addToBagState).to(equal(AddToBagState.add))
                    expect(subject.selectedColor).to(beNil())
                    expect(subject.selectedSize).to(beNil())
                    expect(subject.selectedSKU).to(beNil())
                }
            }
            
            describe("increasing the amount to purchase") {
                context("when adding one more within limit") {
                    beforeEach {
                        subject = PDPState.testMake(amountToAddToBag: 1)
                        state = subject.addOneMoreToPurchase()
                    }
                    
                    it("should have added one more to the bag") {
                        let expectedState: PDPStateResult = .success(subject.make(amountToAddToBag: 2))
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when adding one more than is allowed") {
                    beforeEach {
                        subject = PDPState.testMake(amountToAddToBag: 99)
                        state = subject.addOneMoreToPurchase()
                    }
                    
                    it("should have thrown an error and changed no state") {
                        let expectedState: PDPStateResult = .error(.exceededAmountThatCanBeAddedToBag)
                        expect(state).to(equal(expectedState))
                    }
                }
            }
            
            // MARK: An example of how a service can be tested
            
            describe("adding a sku to the bag") {

            }
        }
        
    }
}
