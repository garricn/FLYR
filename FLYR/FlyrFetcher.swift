//
//  PhotoFetcher.swift
//  FLYR
//
//  Created by Garric Nahapetian on 8/6/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import UIKit
import GGNObservable

typealias CKRecords = [CKRecord]
typealias Flyrs = [Flyr]

protocol FlyrFetchable {
    var output: Observable<Flyrs> { get }
    var refreshOutput: Observable<Flyrs> { get }
    var errorOutput: Observable<Error?> { get }
    func fetch(with query: CKQuery)
    func fetch(with operation: CKQueryOperation, and query: CKQuery)
    func fetch(with operation: CKQueryOperation, completion: @escaping (FlyrFetcher.Response) -> Void)
}

class FlyrFetcher: FlyrFetchable {
    let output = Observable<Flyrs>()
    let refreshOutput = Observable<Flyrs>()
    let errorOutput = Observable<Error?>()

    private let database: Database
    private var cursor: CKQueryCursor?

    init(database: Database) {
        self.database = database
    }

    func fetch(with operation: CKQueryOperation, and query: CKQuery) {
        database.add_(operation)
        fetch(with: query)
    }

    func fetch(with query: CKQuery) {
        database.perform(query, completion: completion)
    }
    
    func fetch(with operation: CKQueryOperation, completion: @escaping (FlyrFetcher.Response) -> Void) {
        var records: [CKRecord] = []
        
        operation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            let response: Response
            
            if let cursor = cursor {
                self.cursor = cursor
                let flyrs = records.flatMap(toFlyr)
                response = .successful(flyrs)
            } else if let error = error {
                response = .notSuccessful(error)
            } else {
                let err: FLYR.Response.Error = .unknown
                response = .notSuccessful(err)
            }
            
            completion(response)
        }
        
        database.add_(operation)
    }
    
    private func completion(with response: FLYR.Response) {
        switch response {
        case .successful(let records):
            guard let records = records as? CKRecords else { return }
            let flyrs = records.flatMap(toFlyr)
            output.emit(flyrs)
            refreshOutput.emit(flyrs)
        case .notSuccessful(let error):
            errorOutput.emit(error)
        }
    }
    
    // MARK: - Nested Types
    
    enum Response {
        case notSuccessful(Swift.Error)
        case successful(Flyrs)
    }
}

func toFlyr(_ record: CKRecord) -> Flyr? {
    return Flyr(record: record)
}
