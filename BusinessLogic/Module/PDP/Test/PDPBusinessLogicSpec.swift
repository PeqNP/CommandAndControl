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
                        let expectedState: PDPStateResult = .success(PDPState.testMake(amountToAddToBag: 2))
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
            
            describe("reset add to bag state") {
                beforeEach {
                    subject = PDPState.testMake(addToBagState: .adding)
                    state = subject.resetAddSKUToBag()
                }
                
                it("should set state to `adding`") {
                    let expectedState: PDPStateResult = .success(subject.make(addToBagState: .add))
                    expect(state).to(equal(expectedState))
                }
            }
            
            describe("adding a sku to the bag") {
                context("when add to bag state is valid; SKU is selected") {
                    beforeEach {
                        subject = PDPState.testMake(addToBagState: .add, selectedSKU: SKU.testMake(id: 1))
                        state = subject.addSKUToBag()
                    }
                    
                    it("should set state to `adding`") {
                        let expectedState: PDPStateResult = .success(subject.make(addToBagState: .adding))
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when attempting to add to bag when in the process of adding") {
                    beforeEach {
                        subject = PDPState.testMake(addToBagState: .adding)
                        state = subject.addSKUToBag()
                    }
                    
                    it("should return error `operation in progress`") {
                        let expectedState: PDPStateResult = .error(.operationInProgress)
                        expect(state).to(equal(expectedState))
                    }
                }
                
                context("when a SKU is already in the process of being added") {
                    beforeEach {
                        subject = PDPState.testMake(addToBagState: .add, selectedSKU: nil)
                        state = subject.addSKUToBag()
                    }
                    
                    it("should return error `SKU is not selected`") {
                        let expectedState: PDPStateResult = .error(.skuIsNotSelected)
                        expect(state).to(equal(expectedState))
                    }
                }
            }
            
            describe("set added to bag") {
                beforeEach {
                    subject = PDPState.testMake(addToBagState: .adding)
                    state = subject.addedSKUToBag()
                }
                
                it("should set state to `adding`") {
                    let expectedState: PDPStateResult = .success(subject.make(addToBagState: .added))
                    expect(state).to(equal(expectedState))
                }
            }
        }
        
    }
}
