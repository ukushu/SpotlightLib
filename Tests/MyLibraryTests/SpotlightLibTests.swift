import XCTest
@testable import SpotlightLib


final class SpotlightLibTests: XCTestCase {
    func test_sync_async_call_sameResults() throws {
        let config = SpotlightConfig(daysRange: .last(days: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],//["/Users/uks/Desktop"],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config).maybeSuccess!
        
        print("results1: \(results1.count)")
        
        XCTAssertTrue(results1.count > 0)
        
        queue.async {
            let results2 = SpotLight.getRecentFilesR(config).maybeSuccess!
            
            print("results2: \(results2.count)")
            
            XCTAssertEqual(results1.count, results2.count)
        }
    }
    
    func test_absentIgnoredDir() throws {
        let config = SpotlightConfig(daysRange: .last(days: 100),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: ["/Users/uks/Desktop"],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config).maybeSuccess!
        
        let results2 = results1.filter{ !( $0.item.path?.starts(with: "/Users/uks/Desktop/") ?? true) }
        
        XCTAssertEqual(results1.count, results2.count)
    }
    
    func test_absentIgnoredExt() throws {
        let config = SpotlightConfig(daysRange: .last(days: 100),
                                      watchList: watchlist,
                                      ignoredExts: ["txt","pdf","png","mp4"],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config).maybeSuccess!
        
        let results2 = results1.filter{ !( $0.item.path?.endsWith(oneOf: ["txt","pdf","png","mp4"]) ?? true) }
        
        XCTAssertEqual(results1.count, results2.count)
    }
    
    ///IMPORTANT!
    ///If this test failed - make sure you have file modified today!
    ///And 10 days ago!!!!
    ///This is unstable test!
    func test_fromToRange() throws {
        let config1 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 0, toDaysAgo: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config1).maybeSuccess!.map{ $0.item.path }
        
        let config2 = SpotlightConfig(daysRange: .last(days: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results2 = SpotLight.getRecentFilesR(config2).maybeSuccess!.map{ $0.item.path }
        
        XCTAssertEqual(results1, results2)
    }
    
    func test_fromToRangeQuery() throws {
        let config1 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 0, toDaysAgo: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let config2 = SpotlightConfig(daysRange: .last(days: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let text1 = getQueryStr(config1)
        let text2 = getQueryStr(config2)
        
        XCTAssertEqual(text1, text2)
    }
}

///////////
///HELPERS
///////////
let queue = DispatchQueue.init(label: "test", qos: .background)


let watchlist = [
"/Users/uks/Desktop",
"/Users/uks/Documents",
"/Users/uks/Downloads",
"/Users/uks/Movies",
"/Users/uks/Music",
"/Users/uks/Pictures",
"/Users/uks/Public",
"/Users/uks/Dropbox",
"/Users/uks/GoogleDrive",
"/Users/uks/My Drive",
"/Users/uks/Recordings"
]

fileprivate extension MDItem {
    var latestDate: Date {
        var dates: [Date] = []
        
//        if let date = self.dateAdded {
//            dates.append(date)
//        }
        
        if let date = self.dateContentModif {
            dates.append(date)
        }
        
        if let date = self.dateCreate {
            dates.append(date)
        }
        
        if let date = self.dateLastAttrChange {
            dates.append(date)
        }
        
//        if let date = self.dateLastUse {
//            dates.append(date)
//        }
        
        return dates.max()!
    }
}

fileprivate extension Date {
    func removingTimeStamp() -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))
        else { fatalError("Failed to strip time from Date object") }
        
        return date
    }
}
