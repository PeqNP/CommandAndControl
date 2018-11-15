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
            var state: PDPStateResult!
            
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
