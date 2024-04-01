import Foundation
import AppKit
//import Essentials

internal extension String {
    var FS: FSstr {
        FSstr(path: self)
    }
}

internal class FSstr {
    public let path: String
    
    public init(path: String ) {
        self.path = path
    }
    
    public var info: FSFileInfo {
        return FSFileInfo(obj: self)
    }
    
    private var fmDefault: FileManager { FileManager.default }
}

internal extension FSstr {
    var exist: Bool {
        return fmDefault.fileExists(atPath: path)
    }
}
