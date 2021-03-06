//
//  UploadKeeper.swift
//  TheGreatGame
//
//  Created by Oleg Dreyman on 13.06.17.
//  Copyright © 2017 The Great Game. All rights reserved.
//

import Foundation
import Shallows
import Alba

internal final class UploadConsistencyKeeper<Upload : Equatable> {
    
    let actual: Retrieve<Upload>
    let lastUploaded: Cache<Void, Upload>
    let name: String
    
    var reupload: (Upload) -> ()
    
    init(actual: Retrieve<Upload>, lastUploaded: Cache<Void, Upload>, name: String, reupload: @escaping (Upload) -> ()) {
        self.actual = actual
        self.lastUploaded = lastUploaded
        self.name = name
        self.reupload = reupload
    }
    
    func declare(didUploadFavorites: Subscribe<Upload>) {
        didUploadFavorites.subscribe(self, with: UploadConsistencyKeeper.didUploadFavorites)
    }
    
    func didUploadFavorites(_ upload: Upload) {
        lastUploaded.set(upload)
    }
    
    func check(listeningTo updates: Subscribe<Void>) {
        updates.subscribe(self, with: UploadConsistencyKeeper.check)
    }
    
    func check() {
        let name = self.name
        printWithContext("(uploads-\(name)) Checking if last update was properly uploaded")
        zip(actual, lastUploaded.asReadOnlyCache()).retrieve { (result) in
            guard let value = result.value else {
                fault("(uploads-\(name)) Both caches should be defaulted")
                return
            }
            let favors = value.0
            let lasts = value.1
            if lasts != favors {
                self.reupload(favors)
            } else {
                printWithContext("(uploads-\(name)) It was")
            }
        }
    }
        
}

//extension UploadConsistencyKeeper where Upload == Set<Team.ID> {
//    
//    convenience init(favorites: Retrieve<Set<Team.ID>>, diskCache: Cache<String, Data>) {
//        let last: Cache<Void, Set<Team.ID>> = diskCache
//            .mapJSONDictionary()
//            .mapBoxedSet()
//            .singleKey("last-uploaded-favorites-teams")
//            .defaulting(to: [])
//        self.init(actual: favorites, lastUploaded: last, name: "teams")
//    }
//    
//}
