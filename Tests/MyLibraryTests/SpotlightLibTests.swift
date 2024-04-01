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
