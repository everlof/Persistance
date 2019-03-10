// MIT License
//
// Copyright (c) 2018 David Everlöf
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
@testable import Persistance

struct IntContainer: Identifiable, Comparable, Codable {
    let int: Int
    let identifier: String

    public static func == (lhs: IntContainer, rhs: IntContainer) -> Bool {
        return lhs.int == rhs.int
    }

    public static func < (lhs: IntContainer, rhs: IntContainer) -> Bool {
        return lhs.int < rhs.int
    }

}

class PersistedCollectionTests: XCTestCase {

    let storage = try! Storage(isTransient: true)

    override func setUp() {

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleCollection() {
        let intContainer = IntContainer(int: 1, identifier: "1")
        try! storage.persist(intContainer)

        let collection = try! PersistedCollection<IntContainer>(storage: storage)
        XCTAssertEqual(collection.array.count, 1)
    }

}
