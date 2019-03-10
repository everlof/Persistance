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

import Foundation

extension NSNotification.Name {
    public static let insertedItem = Notification.Name("PersistentCollectionNotifications.insertedItem")
}

public struct PersistedCollectionKeys {
    private init() { }
    public static let indexKey = "indexKey"
}

public class PersistedCollection<T> where T: Comparable, T: Storagable {

    public var array: [T]

    public let path: URL

    public init(storage: Storage) throws {
        path = try storage.directory(for: T.self)
        array = [T]()
        do {
            for file in try FileManager.default.contentsOfDirectory(atPath: path.path) {
                array.append(try storage.load(id: file))
            }
        } catch {
            // If there's errors here, it may just be that the folder doesnt exists
        }
    }

    @discardableResult
    public func add(_ object: T) -> Int {
        // Use CFArrayBSearchValues?
        let atIndex = array.binarySearch(predicate: { $0 < object })
        defer {
            NotificationCenter.default.post(name: .insertedItem, object: self, userInfo: [
                PersistedCollectionKeys.indexKey: atIndex
                ])
        }
        array.insert(object, at: atIndex)
        return atIndex
    }

    @discardableResult
    public func remove(at index: Int) -> Int {
        array.remove(at: index)
        return index
    }

}
