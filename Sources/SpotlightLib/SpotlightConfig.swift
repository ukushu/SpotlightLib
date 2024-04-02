
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
