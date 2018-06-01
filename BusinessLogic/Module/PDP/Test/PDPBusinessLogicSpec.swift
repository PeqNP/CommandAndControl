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
            
            describe("default values") {
                var product: Product!
                
                beforeEach {
                    product = Product.testMake(id: 1)
                    bagService = FakeBagService()
                    subject = PDPBusinessLogic(bagService: bagService, product: product)
                }
                
                it("should return the correct ProductID") {
                    expect(subject.productID).to(equal(product.id))
                }
                
                it("should set immutable properties correctly") {
                    expect(subject.state.productName).to(equal(product.name))
                    expect(subject.state.price).to(equal(product.price))
                    expect(subject.state.skus).to(equal(product.skus))
                }
                
                it("should have set the correct default values for mutable values") {
                    expect(subject.state.amountToAddToBag).to(equal(1))
                    expect(subject.state.selectedColor).to(beNil())
                    expect(subject.state.selectedSize).to(beNil())
                    expect(subject.state.selectedSKU).to(beNil())
                }
                
            }
        }
    }
}
