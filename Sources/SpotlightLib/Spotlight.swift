import Foundation
import CoreSpotlight
import SwiftUI
import Essentials

public struct SpotlightConfig {
    let daysCount: SlDaysRange
    
    let watchList: [String]
    
    let ignoredExts: [String]
    let ignoredDirs: [String]
    let ignoredFiles: [String]
}

public struct SpotLight2 {
    private static func getRecentFiles(_ config: SpotlightConfig) -> ([MDItemPair]) {
        let mdItems = getMDs(config)
        
        let mdPairs = mdItems.compactMap { MDItemPair($0) }
        
        //CAN BE OPTIMIZED?
        let mdPairs2 = mdPairs.doBasicFiltering(config)
        
        return mdPairs2.filter{ !$0.url.FS.info.isHidden }
    }
    
    static func getRecentFilesR(_ config: SpotlightConfig) -> R<([MDItemPair])> {
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

fileprivate extension Array where Element == MDItemPair {
    func doBasicFiltering(_ config: SpotlightConfig) -> [MDItemPair] {
        let ignoredDirs = config.ignoredDirs
        let ignoredDirsSlash = config.ignoredDirs.map{ "\($0)/" }
        let ignoredFiles = config.ignoredFiles
        let extensions = config.ignoredExts
        
        let mds = self
            .filter { !$0.url.path.FS.info.isHidden }
            //must be after !isHidden
            .cleanupFromPackageContents()
            .filter { !$0.url.path.startsWith(oneOf: ignoredDirsSlash ) }
            .filter { !ignoredDirs.contains($0.url.path) }
            .filter { !ignoredFiles.contains($0.url.path) }
        
        let mds2 = mds
            //not "endsWith", but "contains" because of folders-packages
            .filter { !$0.url.path.endsWith(oneOf: extensions) }
       
//        // TempCode
//        let a = mds2.filter{ $0.url.path.contains(oneOf: [".photolibrary",".photoslibrary"])}.count
//        //AppCore.log(title: "Spotlight", msg: "photoslibrary: \(a)")
//        // TempCode
        
        return mds2
    }
}

fileprivate extension Array where Element == MDItemPair {
    func cleanupFromPackageContents() -> [MDItemPair] {
        let packagesPaths = self
            .map { $0.url.deletingLastPathComponent() }
            .filter { $0.path.contains(".") }
            .compactMap { url -> String? in
                if url.path.FS.info.isPackage {
                    return "\(url.path)/"
                }
                
                if let potentialPackage = url.path.extract(regExp: ".*[.].+?[/]").maybeSuccess,
                   potentialPackage.FS.info.isPackage {
                    return "\(url.path)/"
                }
                
                return nil
            }
            .distinct()
        
        //AppCore.log(title: "Spotlight", msg: "before filter from packages content: \(self.count)")
        
        let result = self
            .filter{ !$0.url.path.startsWith(oneOf: packagesPaths) }
        
        //AppCore.log(title: "Spotlight", msg: "after filter from packages content: \(result.count)")
        
        return result
    }
}

extension Array where Element == String {
    func cleanupFromPackageContents() -> [String] {
        return self.compactMap { path -> (String, String)? in
            if let parent = path.deletingLastPathComponent() {
                return (path, "\(parent)")
            }
            
            return nil
        }
        .compactMap { args -> String in
            let (path, parent) = args
            
            if parent.contains(".") {
                if parent.FS.info.isPackage {
                    return parent
                }
                
                if let potentialPackage = parent.extract(regExp: ".*[.].+?[/]").maybeSuccess,
                   potentialPackage.FS.info.isPackage {
                    return potentialPackage.trimEnd("/")
                }
            }
            
            return path
        }
        .distinct()
    }
}

public class MDItemPair {
    public let item: MDItem
    public let url: URL
    
    init?(_ item: MDItem) {
        if let path = item.path {
            self.item = item
            self.url = path.asURL()
            
            return
        }
        
        return nil
    }
}

public enum SlDaysRange {
    case last(days: Int)
//    case daysRange(from: Date, to: Date)
}
