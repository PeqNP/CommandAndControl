/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

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
                        product = Product.testMake(id: 1)
                        subject = PDPBusinessLogic(bagService: bagService, state: PDPState.testMake(amountToAddToBag: 99))
                        state = subject.addOneMoreToPurchase()
                    }
                    
                    it("should have added one more to the bag") {
                        expectedState = .error(.exceededAmountThatCanBeAddedToBag)
                        expect(state).to(equal(expectedState))
                    }
                }
            }
        }
    }
}
