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

public protocol Identifiable {
    var identifier: String { get }
}

public typealias Storagable = Codable & Identifiable

public class Storage {

    public enum Error: Swift.Error {
        case noFile
        case invalidFileType
        case decodingError
    }

    public let isTransient: Bool

    public let base: URL

    public init(isTransient: Bool = false) throws {
        base = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("storage")

        if !FileManager.default.fileExists(atPath: base.path) {
            try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true, attributes: [:])
        }
        
        self.isTransient = isTransient
        print("Storage initiated with location => \(base)")
    }

    deinit {
        if isTransient { try? deleteAll() }
    }


    internal func directory<T : Storagable>(for storagableType: T.Type) throws -> URL {
        let typeName = String(describing: storagableType).lowercased()
        return base.appendingPathComponent(typeName)
    }

    private func directory<T : Storagable>(for storagableType: T.Type, id: String) throws -> URL {
        return try directory(for: storagableType).appendingPathComponent(String(format: "%@", id))
    }

    private func file<T : Storagable>(for storagableType: T.Type, id: String) throws -> URL {
        let folder = try directory(for: storagableType, id: id)
        return folder.appendingPathComponent(String(format: "object.json", id))
    }

    public func deleteAll() throws {
        let urls = try FileManager.default.contentsOfDirectory(at: base, includingPropertiesForKeys: nil, options: [])
        for url in urls {
            try FileManager.default.removeItem(at: url)
        }
    }

    public func persist<T : Storagable>(_ encodable: T) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(encodable)
        let folder = try directory(for: type(of: encodable), id: encodable.identifier)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [:])
        }

        let location = try file(for: type(of: encodable), id: encodable.identifier)
        try encoded.write(to: location, options: .atomicWrite)
        print("persist(id = \(encodable.identifier)) to location=\(location)")
    }

    public func load<T: Storagable>(id: String) throws -> T {
        let location = try file(for: T.self, id: id)
        print("load(id = \(id)) from location=\(location)")

        var isDirectory: ObjCBool = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: location.path, isDirectory: &isDirectory) {
            throw Error.noFile
        }

        if isDirectory.boolValue {
            throw Error.invalidFileType
        }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: Data(contentsOf: location))
        } catch {
            throw Error.decodingError
        }
    }

}
