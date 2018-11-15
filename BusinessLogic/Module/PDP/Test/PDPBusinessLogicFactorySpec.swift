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

class PDPBusinessLogicFactorySpec: QuickSpec {
    override func spec() {
        
        describe("Given a PDPBusinessLogicFactory") {
            var subject: PDPBusinessLogicFactory!
            
            beforeEach {
                subject = PDPBusinessLogicFactory()
            }
            
            describe("initializing") {
                var product: Product!
                var state: PDPState!
                
                beforeEach {
                    product = Product.testMake(id: 1, name: "Shoes" /* TODO: price, skus */)
                    state = (subject.makeFromProduct(product) as! PDPState)
                }
                
                it("should return the correct values") {
                    expect(state.selectedSKUID).to(beNil())
                }
                
                it("should have set the correct state default values") {
                    expect(state.productID).to(equal(product.id))
                    expect(state.productName).to(equal(product.name))
                    expect(state.price).to(equal(product.price))
                    expect(state.skus).to(equal(product.skus))
                    
                    expect(state.amountToAddToBag).to(equal(0))
                    expect(state.addToBagState).to(equal(AddToBagState.add))
                    expect(state.selectedColor).to(beNil())
                    expect(state.selectedSize).to(beNil())
                    expect(state.selectedSKU).to(beNil())
                }
            }
        }
        
    }
}
