import BrightFutures
import Quick
import Nimble
import Result

extension Future {
    func waitUntilCompleted(file: FileString = #file, line: UInt = #line, timeout: TimeInterval = AsyncDefaults.Timeout) {
        var isComplete = false
        self.onComplete { _ in
            isComplete = true
        }
        expect(isComplete, file: file, line: line).toEventually(beTrue(), timeout: timeout)
        
        // FIXME: The number of `expect`s must be the number of `callbacks`. The problem is `callbacks` is private. We're assuming that there will only be two calls to `onComplete`.
        expect(true).toEventually(beTrue())
        expect(true).toEventually(beTrue())
    }
}

extension Promise {
    func waitUntilCompleted(file: FileString = #file, line: UInt = #line) {
        future.waitUntilCompleted(file: file, line: line)
    }
}
