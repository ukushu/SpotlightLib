import XCTest
@testable import SpotlightLib


final class SpotlightLibTests: XCTestCase {
    func test_blablabla() throws {
        let config = SpotlightConfig(daysRange: .last(days: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],//["/Users/uks/Desktop"],
                                      ignoredFiles: []
        )
        
        let blablabla = URL.userHome.appendingPathComponent("Desktop").appendingPathComponent("BLA-BLA-BLA")
        blablabla.makeSureDirExist()
        
        XCTAssertTrue(blablabla.exists)
        
        let results1 = SpotLight.getRecentFilesR(config).maybeSuccess!
        
        let a = results1.map { $0.url.path }.filter { $0.contains("BLA-BLA-BLA") }
        
        XCTAssertTrue(a.count == 1)
    }
    
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
    
    func test_fromToRange_p2() throws {
        let configOrig = SpotlightConfig(daysRange: .last(days: 50),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let resultsOrig = SpotLight.getRecentFilesR(configOrig).maybeSuccess!.map{ $0.item.path }
        
        let text0 = getQueryStr(configOrig)
        print(text0)
        print("------------")
        
        XCTAssertEqual(resultsOrig, resultsOrig.distinct())
        
        let config1 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 0, toDaysAgo: 10),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config1).maybeSuccess!.map{ $0.item.path }
        
        let text1 = getQueryStr(config1)
        print(text1)
        print("------------")
        XCTAssertEqual(results1, results1.distinct())
        
        let config2 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 11, toDaysAgo: 50),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results2 = SpotLight.getRecentFilesR(config2).maybeSuccess!.map{ $0.item.path }
        
        
        let text2 = getQueryStr(config2)
        print(text2)
        print("------------")
        XCTAssertEqual(results2, results2.distinct())
//        
//        let config3 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 51, toDaysAgo: 100),
//                                      watchList: watchlist,
//                                      ignoredExts: [],
//                                      ignoredDirs: [],
//                                      ignoredFiles: []
//        )
//        
//        let results3 = SpotLight.getRecentFilesR(config3).maybeSuccess!.map{ $0.item.path }
        
        
//        let text3 = getQueryStr(config3)
//        print(text3)
//        print("------------")
//        XCTAssertEqual(results3, results3.distinct())
        
        let resultsCombined = results1.appending(contentsOf: results2)//.appending(contentsOf: results3)
        
        XCTAssertEqual(resultsOrig.count, resultsCombined.count)
//        XCTAssertEqual(resultsOrig, resultsCombined)
    }
    
    func test_fromToRangeQuery() throws {
        let config1 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 0, toDaysAgo: 100),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let config2 = SpotlightConfig(daysRange: .last(days: 100),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let text1 = getQueryStr(config1)
        let text2 = getQueryStr(config2)
        
        XCTAssertEqual(text1, text2)
    }
    
    func test_fromToRangeQuery2() throws {
        let configOrig = SpotlightConfig(daysRange: .last(days: 100),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let resultsOrig = SpotLight.getRecentFilesR(configOrig).maybeSuccess!.map{ $0.item.path }
        
        XCTAssertEqual(resultsOrig, resultsOrig.distinct())
        
        let config1 = SpotlightConfig(daysRange: .daysRange(fromDaysAgo: 0, toDaysAgo: 100),
                                      watchList: watchlist,
                                      ignoredExts: [],
                                      ignoredDirs: [],
                                      ignoredFiles: []
        )
        
        let results1 = SpotLight.getRecentFilesR(config1).maybeSuccess!.map{ $0.item.path }
        
        XCTAssertEqual(resultsOrig.count, results1.count)
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
