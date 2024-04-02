import Foundation
import CoreSpotlight
import SwiftUI
import Essentials

public struct SpotLight {
    private static func getRecentFiles(_ config: SpotlightConfig) -> ([MDItemPair]) {
        let mdItems = getMDs(config)
        
        let mdPairs = mdItems.compactMap { MDItemPair($0) }
        
        //CAN BE OPTIMIZED?
        let mdPairs2 = mdPairs.doBasicFiltering(config)
        
        return mdPairs2.filter{ !$0.url.FS.info.isHidden }
    }
    
    public static func getRecentFilesR(_ config: SpotlightConfig) -> R<([MDItemPair])> {
        if config.watchList.count == 0 {
            return .failure(WTF("No items in Watch List") )
        }
        
        let pairs = getRecentFiles(config)
        
        return .success( pairs )
    }
    
    static func getMDs(_ config: SpotlightConfig) -> [MDItem] {
        var paths: [MDItem] = []
        
        guard let query = MyQuery.getQuery(config) else { return [] }
        
        MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))
        
        for i in 0..<MDQueryGetResultCount(query) {
            if let rawPtr = MDQueryGetResultAtIndex(query, i) {
                let item = Unmanaged<MDItem>.fromOpaque(rawPtr).takeUnretainedValue()
                
                paths.append(item)
            }
        }
        
        return paths
    }
}


////////////////////
///HELPERS
////////////////////

fileprivate func queryProgress_cust(_ notifCenter: CFNotificationCenter?, _ observer: UnsafeMutableRawPointer?, _ name: CFNotificationName?, _ obj: UnsafeRawPointer?, _ cfDict: CFDictionary?) {
}

fileprivate func queryFinish_cust(_ notifCenter: CFNotificationCenter?, _ observer: UnsafeMutableRawPointer?, _ name: CFNotificationName?, _ obj: UnsafeRawPointer?, _ cfDict: CFDictionary?) {
}

fileprivate func queryUpdate_cust(_ notifCenter: CFNotificationCenter?, _ observer: UnsafeMutableRawPointer?, _ name: CFNotificationName?, _ obj: UnsafeRawPointer?, _ cfDict: CFDictionary?) {
    print("UPDATE!!!!")
    
    if let dict = cfDict as? [CFString: [MDItem]] {
        if let b = dict[kMDQueryUpdateAddedItems] {
            print("added items: \(b.count)")
        }
        
        if let c = dict[kMDQueryUpdateChangedItems] {
            print("changed items: \(c.count)")
        }
        
        if let d = dict[kMDQueryUpdateRemovedItems] {
            print("removed items: \(d.count)")
        }
    }
}
