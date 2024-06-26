import Foundation
import CoreSpotlight
import Essentials

internal struct MyQuery {
    static func getQuery(_ config: SpotlightConfig) -> MDQuery? {
        let queryString = getQueryStr(config)
        //AppCore.log(title: "Spotlight", msg: queryString)
        
        let searchScopes = getSearchScopes(config)
        
        //guard count > 0
        guard searchScopes.1 > 0 else { return nil }
        
        let sorting = getSorting()
        
        let query = MDQueryCreate(kCFAllocatorDefault, queryString as CFString, nil, sorting)
        
        MDQuerySetSortComparatorBlock(query, {
            if let date1 = $0?.pointee?.takeRetainedValue() as? Date,
               let date2 = $1?.pointee?.takeRetainedValue() as? Date {
                return date1 < date2 ? .compareGreaterThan : .compareLessThan
              }
            
            return CFComparisonResult.compareEqualTo
        })
        
        MDQuerySetSearchScope(query, searchScopes.0, 0)
        
//        MDQueryEnableUpdates(query)
        
        MDQuerySetDispatchQueue(query, DispatchQueue(label: "background", qos: .userInteractive) )
        
        let bParams = MDQueryBatchingParams(first_max_num: 100, first_max_ms: 50, progress_max_num: 300, progress_max_ms: 500, update_max_num: 300, update_max_ms: 100)
        MDQuerySetBatchingParameters(query, bParams)
        
        return query
    }
    
    private static func getSearchScopes(_ config: SpotlightConfig) -> (CFArray, Int) {
        let searchScopesGlobal: [String] = config.watchList.filter{ $0.FS.exist }.map { $0 }
        
        return ((searchScopesGlobal as CFArray), searchScopesGlobal.count )
    }
    
    private static func getSorting() -> CFArray {
        return [
            kMDItemFSContentChangeDate,
            kMDItemContentModificationDate,
            kMDItemDateAdded,
            kMDItemAttributeChangeDate,
            kMDItemFSCreationDate,
            kMDItemLastUsedDate,
            kMDItemDownloadedDate,
            kMDItemAttributeChangeDate,
            kMDItemContentCreationDate
         ] as CFArray
    }
}

////////////////
//HELPERS
////////////////

internal func getQueryStr(_ config: SpotlightConfig) -> String {
    if case .last(let days) = config.daysRange {
        return """
               ( ( \( timeQueryPart(lastDays: days ) )
               && (!( \( extensionsPart(exts: config.ignoredExts.appending(contentsOf: ["app"]) ) ) ) ))
               )
               """
    }
    
    if case .daysRange(let fromDay, let toDay) = config.daysRange {
        fatalError("Does not work properly yet")
        
        return """
               ( ( \( timeQueryPart(from: fromDay, to: toDay ) )
               && (!( \( extensionsPart(exts: config.ignoredExts.appending(contentsOf: ["app"]) ) ) ) ))
               )
               """
    }
    
    return ""
}

internal func timeQueryPart(lastDays days: Int) -> String {
    return "InRange(kMDItemContentCreationDate,$time.today(-\(days)d),$time.today(+1d)) || InRange(kMDItemFSContentChangeDate,$time.today(-\(days)d),$time.today(+1d)) || InRange(kMDItemFSCreationDate,$time.today(-\(days)d),$time.today(+1d)) || InRange(kMDItemDateAdded,$time.today(-\(days)d),$time.today(+1d))"
}

internal func timeQueryPart(from fromDay: Int, to toDay: Int) -> String {
    let toStr = (1 - fromDay) >= 0 ? "+\(1 - fromDay)" : "\(1 - fromDay)"
    
    return "InRange(kMDItemContentCreationDate,$time.today(-\(toDay)d),$time.today(\(toStr)d)) || InRange(kMDItemFSContentChangeDate,$time.today(-\(toDay)d),$time.today(\(toStr)d)) || InRange(kMDItemFSCreationDate,$time.today(-\(toDay)d),$time.today(\(toStr)d)) || InRange(kMDItemDateAdded,$time.today(-\(toDay)d),$time.today(\(toStr)d))"
}

func extensionsPart(exts: [String]) -> String {
    exts.map{ "(_kMDItemFileName = \"*.\($0)\"c)" }.joined(separator: " || ")
}
