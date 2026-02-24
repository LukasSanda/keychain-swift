//
//  ConcurrencyTests.swift
//  KeychainSwift
//
//  Created by Eli Kohen on 08/02/2017.
//

import XCTest
import Darwin
@testable import KeychainSwift

class ConcurrencyTests: XCTestCase, @unchecked Sendable {

    var obj: KeychainSwift!

    override func setUp() {
        super.setUp()

        obj = KeychainSwift()
        try? obj.clear()
        obj.lastQueryParameters = nil
    }

    // MARK: - addSynchronizableIfRequired

    @MainActor
    func testConcurrencyDoesntCrash() {
        let expectation1 = self.expectation(description: "Wait for write loop")
        let expectation2 = self.expectation(description: "Wait for write loop")

        let dataToWrite = "{ asdf ñlk BNALSKDJFÑLKJ ZÑCLXKJ ÑALSKDFJÑLKASJDFÑLKJASDÑFLKJAÑSDLKFJÑLKJ}"
        try? obj.set(dataToWrite, forKey: "test-key")

        nonisolated(unsafe) var writes: Int64 = 0

        // Read queues — call operations directly, no async main-thread round-trip needed.
        // The original design bounced completions via DispatchQueue.main.asyncAfter(+5ms),
        // creating a main-thread bottleneck (3800 callbacks × 5ms > 30s timeout on macOS).
        let readQueue = DispatchQueue(label: "ReadQueue")
        readQueue.async {
            for _ in 0..<400 { let _ = try? self.obj.get("test-key") }
        }
        let readQueue2 = DispatchQueue(label: "ReadQueue2")
        readQueue2.async {
            for _ in 0..<400 { let _ = try? self.obj.get("test-key") }
        }
        let readQueue3 = DispatchQueue(label: "ReadQueue3")
        readQueue3.async {
            for _ in 0..<400 { let _ = try? self.obj.get("test-key") }
        }

        let deleteQueue = DispatchQueue(label: "deleteQueue")
        deleteQueue.async {
            for _ in 0..<400 { try? self.obj.delete("test-key") }
        }
        let deleteQueue2 = DispatchQueue(label: "deleteQueue2")
        deleteQueue2.async {
            for _ in 0..<400 { try? self.obj.delete("test-key") }
        }

        let clearQueue = DispatchQueue(label: "clearQueue")
        clearQueue.async {
            for _ in 0..<400 { try? self.obj.clear() }
        }
        let clearQueue2 = DispatchQueue(label: "clearQueue2")
        clearQueue2.async {
            for _ in 0..<400 { try? self.obj.clear() }
        }

        let writeQueue = DispatchQueue(label: "WriteQueue")
        writeQueue.async {
            for _ in 0..<500 {
                if (try? self.obj.set(dataToWrite, forKey: "test-key")) != nil {
                    OSAtomicIncrement64(&writes)
                }
            }
            expectation1.fulfill()
        }
        let writeQueue2 = DispatchQueue(label: "WriteQueue2")
        writeQueue2.async {
            for _ in 0..<500 {
                if (try? self.obj.set(dataToWrite, forKey: "test-key")) != nil {
                    OSAtomicIncrement64(&writes)
                }
            }
            expectation2.fulfill()
        }

        for _ in 0..<1000 {
            try? self.obj.set(dataToWrite, forKey: "test-key")
            let _ = try? self.obj.get("test-key")
        }
        self.waitForExpectations(timeout: 30, handler: nil)

        XCTAssertEqual(1000, writes)
    }
}
