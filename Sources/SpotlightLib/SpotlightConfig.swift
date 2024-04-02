
public struct SpotlightConfig {
    let daysRange: SlDaysRange
    
    let watchList: [String]
    
    let ignoredExts: [String]
    let ignoredDirs: [String]
    let ignoredFiles: [String]
    
    public init(daysRange: SlDaysRange, watchList: [String], ignoredExts: [String], ignoredDirs: [String], ignoredFiles: [String]) {
        self.daysRange = daysRange
        self.watchList = watchList
        self.ignoredExts = ignoredExts
        self.ignoredDirs = ignoredDirs
        self.ignoredFiles = ignoredFiles
    }
}

public enum SlDaysRange {
    case last(days: Int)
    
    /// (Usage examples below)
    ///
    /// fromDaysAgo: 0, toDaysAgo: 10 - from today to 10 days ago; range
    ///
    /// fromDaysAgo: 5,  toDaysAgo: 10 - from 5 days ago to 10 days ago range
    case daysRange(fromDaysAgo: Int, toDaysAgo: Int)
}
