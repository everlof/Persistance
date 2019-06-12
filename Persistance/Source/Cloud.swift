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
import CloudKit

public class Cloud {

    private(set) static var container = CKContainer.default()

    private static func populate<T>(record: CKRecord, from: T) {
        let mirror = Mirror(reflecting: from)
        for child in mirror.children {
            if let label = child.label, let value = child.value as? __CKRecordObjCValue {
                record[label] = value
            }
        }
    }

    public static func internalCreate<T: Identifiable>(object: T) {
        let recordType = String(describing: type(of: object))
        let recordId = CKRecord.ID(recordName: object.identifier)
        let record = CKRecord(recordType: recordType, recordID: recordId)

        populate(record: record, from: object)

        Cloud.container.privateCloudDatabase.save(record) { (record, error) in
            print("save -> internalCreate success => \(String(describing: record))")
        }
    }

    public static func internalUpdate<T: Identifiable>(object: T, record: CKRecord) {
        populate(record: record, from: object)
        Cloud.container.privateCloudDatabase.save(record) { (record, error) in
            print("save -> internalUpdate success => \(String(describing: record))")
        }
    }

    public static func save<T: Identifiable>(_ object: T) {
        let recordId = CKRecord.ID(recordName: object.identifier)

        Cloud.container.privateCloudDatabase.fetch(withRecordID: recordId) { (record, error) in
            if let record = record {
                internalUpdate(object: object, record: record)
            } else {
                internalCreate(object: object)
            }
        }

        return
    }

}
