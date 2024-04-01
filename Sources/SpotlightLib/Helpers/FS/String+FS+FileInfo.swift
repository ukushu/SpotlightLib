import Foundation
import Quartz

internal class FSFileInfo {
    private let obj: FSstr
    public var path: String { obj.path }
    
    public init(obj: FSstr) {
        self.obj = obj
    }
}

internal extension FSFileInfo {
    var name: String { path.split(separator: "/").last?.asStr() ?? "failedToGetName" }
    
    var isDirectory: Bool {
        var check: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &check) {
            return check.boolValue
        } else {
            return false
        }
    }
    
    // Package is directory associated with some application as file
    var isPackage: Bool {
        path.ends(with: ".localized") || NSWorkspace.shared.isFilePackage(atPath: path)
    }
    
    @available(macOS 11.0, *)
    var mimeType: UTType? {
        guard let ext = self.path.split(separator: ".").last?.asStr() else { return nil }
        
        let type = UTType(filenameExtension: ext)
        
        return type
    }
}

internal extension FSFileInfo {
    var addedToFSDate: Date? {
        return getAttributes()["kMDItemDateAdded"] as? Date
    }
    
    var lastUseDate: Date? {
        return path.withCString {
            var statStruct = Darwin.stat()
            guard  stat($0, &statStruct) == 0 else { return nil }
            let lastRead = Date(
                timeIntervalSince1970: TimeInterval(statStruct.st_atimespec.tv_sec)
            )
            let lastWrite = Date(
                timeIntervalSince1970: TimeInterval(statStruct.st_mtimespec.tv_sec)
            )
            
            // If you want to include dir entry updates
//            let lastDirEntryChange = Date(
//                timeIntervalSince1970: TimeInterval(statStruct.st_ctimespec.tv_sec)
//            )
            
            return max(lastRead, lastWrite )
        }
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    
    var modificationDate: Date? {
        return attributes?[.modificationDate] as? Date
    }
    
    var fileSizeBytes: UInt64? {
        return attributes?[.size] as? UInt64
    }
    
    var fileSizeString: String? {
        if self.isDirectory {
            return nil
        }
        if let bytes = fileSizeBytes {
            return " - " + ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
        }
        
        return nil
    }
    
    var isHidden: Bool {
        path.asURL().FS.info.isHidden
    }
    
    func getAttributes() -> [String : Any] {
        let attrItem = NSMetadataItem(url: path.asURL() )
        
        if let item = attrItem,
           let attributes = item.values(forAttributes: item.attributes) {
            return attributes
        }
        
        return [:]
    }
}

//////////////////
//HELPERS
/////////////////
fileprivate extension FSFileInfo {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
}
