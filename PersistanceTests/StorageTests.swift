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

struct Person: Identifiable, Codable {
    let name: String
    let socialSecurityNumber: String

    var identifier: String {
        return socialSecurityNumber
    }
}

class StorageTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        try! Storage().deleteAll()
    }

    func testStoragePersist() {
        let storage = try! Storage()
        let person = Person(name: "Nils", socialSecurityNumber: "19800909-1312")
        try! storage.persist(person)
    }

    func testStorageLoadError() {
        let storage = try! Storage()
        XCTAssertThrowsError(try storage.load(id: "invalid-id") as Person, "Throw incorrect") { error in
            XCTAssertEqual(error as! Storage.Error, Storage.Error.noFile)
        }
    }

    func testStorageLoad() {
        let storage = try! Storage()
        let person  = Person(name: "Nils", socialSecurityNumber: "19800909-1312")
        try! storage.persist(person)
        let loaded = try! storage.load(id: person.identifier) as Person

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let str1 = String(data: try! encoder.encode(loaded), encoding: .utf8)!
        let str2 = String(data: try! encoder.encode(person), encoding: .utf8)!
        XCTAssertEqual(str1, str2)

        let m = Mirror(reflecting: person)

        for n in m.children {
            print(n)
            print(type(of: n.value))
        }
    }

}
