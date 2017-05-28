//
//  WatchExtension.swift
//  TheGreatGame
//
//  Created by Олег on 26.05.17.
//  Copyright © 2017 The Great Game. All rights reserved.
//

import Foundation
import Alba
import TheGreatKit
import Shallows

final class WatchExtension {
    
    static let main = WatchExtension()
    
    let phone: Phone
    let imageCache: ImageFetch
    let api: API
    
    init() {
        self.phone = Phone()
        self.imageCache = ImageFetch(diskCache: FileSystemCache.inDirectory(.cachesDirectory, appending: "dev-1-images").mapKeys({ $0.absoluteString }).mapImage())
        self.api = API.macBookSteve()
    }
    
    var updates: Subscribe<Set<Team.ID>> {
        return phone.didReceivePackage.proxy
            .filter({ $0.kind == .favorites })
            .flatMap({ try? FavoritesPackage.unpacked(from: $0) })
            .map({ $0.favs })
    }
    
}