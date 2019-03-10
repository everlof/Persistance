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

class StorageTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        try! Storage().delete()
    }

    func testStoragePersist() {
        let storage = try! Storage()
        let design = Design(uuid: UUID())
        try! storage.persist(design)
    }

    func testStorageLoadError() {
        let storage = try! Storage()
        XCTAssertThrowsError(try storage.load(id: "invalid-id") as Design, "Throw incorrect") { error in
            XCTAssertEqual(error as! Storage.Error, Storage.Error.noFile)
        }
    }

    func testStorageLoad() {
        let storage = try! Storage()
        let d  = Design(uuid: UUID())
        try! storage.persist(d)
        let loaded = try! storage.load(id: d.uuid.uuidString) as Design

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let str1 = String(data: try! encoder.encode(loaded), encoding: .utf8)!
        let str2 = String(data: try! encoder.encode(d), encoding: .utf8)!
        XCTAssertEqual(str1, str2)

        let m = Mirror(reflecting: d)

        for n in m.children {
            print(n)
            print(type(of: n.value))
        }
    }

}
