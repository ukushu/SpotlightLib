import Foundation
import AudioToolbox

internal extension URL {
    var FS: FSurl {
        FSurl(url: self)
    }
}

internal class FSurl {
    public let url: URL
    
    public init(url: URL ) {
        self.url = url
    }
    
    public var info: FSUrlFileInfo {
        return FSUrlFileInfo(obj: self)
    }
    
    private var fmDefault: FileManager { FileManager.default }
}

internal extension FSurl {
    var exist: Bool {
        return fmDefault.fileExists(atPath: url.path)
    }
    
    @discardableResult
    func makeSureDirExist() -> FSurl {
        try? fmDefault.createDirectory(at: self.url, withIntermediateDirectories: true)
        
        return self
    }
}
