//
//  Resolvers.swift
//  FLYR
//
//  Created by Garric Nahapetian on 9/19/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit
import CloudKit

enum Resolved {}

extension Resolved {
    static var appCoordinator: AppCoordinator {
        return AppCoordinator(appState: AppState.loadAppState(), authenticator: Resolved.authenticator)
    }
    
    private static var authenticator: Authenticating {
        return Authenticator(defaultContainer: CKContainer.default())
    }
    
    static var flyrFetcher: FlyrFetchable {
        return FlyrFetcher(database: Resolved.publicDatabase)
    }
    
    static var recordSaver: RecordSaveable {
        return RecordSaver(database: Resolved.publicDatabase)
    }
    
    private static var publicDatabase: Database {
        let container = CKContainer(identifier: Private.iCloudContainerID)
        return container.publicCloudDatabase
    }
}
