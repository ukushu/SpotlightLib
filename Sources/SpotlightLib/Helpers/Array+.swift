
internal extension Array where Element == MDItemPair {
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

internal extension Array where Element == MDItemPair {
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

internal extension Array where Element == String {
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
