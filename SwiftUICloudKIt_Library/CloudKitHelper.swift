//
//  CloudKitHelper.swift
//  SwiftUICloudKit.swift
//
//  Created by Jan Hovland on 06/11/2019.
//

import Foundation
import CloudKit
import SwiftUI

// MARK: - notes
// good to read: https://www.hackingwithswift.com/read/33/overview
//
// important setup in CloudKit Dashboard:
//
// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
// https://www.hackingwithswift.com/read/33/5/a-hands-on-guide-to-the-cloudkit-dashboard
//
// On your device (or in the simulator) you should make sure you are logged into iCloud and have iCloud Drive enabled.

struct CloudKitHelper {
    
    // MARK: - record types
    struct RecordType {
        static let Items = "Items"
    }
    
    struct RecordTypeUser {
        static let User = "User"
    }
    
    // MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    // MARK: - saving to CloudKit
    static func save(item: ListElement, completion: @escaping (Result<ListElement, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.Items)
        itemRecord["text"] = item.text as CKRecordValue
        itemRecord["description"] = item.description as CKRecordValue
        
        CKContainer.default().privateCloudDatabase.save(itemRecord) { (record, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let record = record else {
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                let recordID = record.recordID
                guard let text = record["text"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let description = record["description"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                let listElement = ListElement(recordID: recordID, text: text, description: description)
                completion(.success(listElement))
            }
        }
    }
    
    // MARK: - fetching from CloudKit
    static func fetch(completion: @escaping (Result<ListElement, Error>) -> ()) {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: RecordType.Items, predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["text","description"]
        operation.resultsLimit = 50
        
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let text = record["text"] as? String else { return }
                guard let description = record["description"] as? String else { return }
                
                let listElement = ListElement(recordID: recordID, text: text, description: description)
                completion(.success(listElement))
            }
        }
        
        operation.queryCompletionBlock = { ( _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
            }
            
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    // MARK: - delete from CloudKit
    static func delete(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let recordID = recordID else {
                    completion(.failure(CloudKitHelperError.recordIDFailure))
                    return
                }
                completion(.success(recordID))
            }
        }
    }
    
    // MARK: - modify in CloudKit
    static func modify(item: ListElement, completion: @escaping (Result<ListElement, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["text"] = item.text as CKRecordValue
            record["description"] = item.description as CKRecordValue

            CKContainer.default().privateCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let text = record["text"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    
                    guard let description = record["description"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    
                    let listElement = ListElement(recordID: recordID, text: text, description: description)
                    completion(.success(listElement))
                }
            }
        }
    }
}

