import Foundation

@testable import BusinessLogic

extension PDPBusinessLogicState {
    
    public static func testMake(state: PDPBusinessLogicState = .success(PDPState.testMake())) -> PDPBusinessLogicState {
        return state
    }
}
