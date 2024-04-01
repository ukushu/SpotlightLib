import Foundation

internal class FSUrlFileInfo {
    private let obj: FSurl
    public var url: URL { obj.url }
    
    public init(obj: FSurl) {
        self.obj = obj
    }
}

internal extension FSUrlFileInfo {
    var isDirectory: Bool {
        return url.isDirectory
    }
    
    var isHidden: Bool {
        return (try? url.resourceValues(forKeys: [.isHiddenKey]))?.isHidden == true
    }
}

internal extension URL {
    var isDirectory: Bool {
        // WTF!?!?!??!
        // Is there exist some way to do this CORRECTLY???????
        // WTF!?!?!??!
        
        // the following code woks not always for some reason:
        ///IMPORTANT: this code return false even if file or directory does not exist(!!!)
        // return hasDirectoryPath
        
        // the following code woks not always for some reason:
        //return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
        
        //Code duplicates of path.FS.info.isDirectory
        var check: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &check) {
            return check.boolValue
        } else {
            return false
        }
    }
}
