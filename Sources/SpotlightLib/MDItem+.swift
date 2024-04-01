import Foundation
import Quartz
import QuickLook
import QuickLookThumbnailing

public extension MDItem {
    var path: String? {
        MDItemCopyAttribute(self, kMDItemPath) as? String
    }
    
    var dateLastAttrChange: Date? {
        return MDItemCopyAttribute(self, kMDItemAttributeChangeDate) as? Date
    }
    
    ///1
    var dateLastUse: Date? {
        MDItemCopyAttribute(self, kMDItemLastUsedDate) as? Date
    }
    
    ///2
    var dateContentModif: Date? {
        MDItemCopyAttribute(self, kMDItemContentModificationDate) as? Date
    }
    ///3
    var dateAdded: Date? {
        MDItemCopyAttribute(self, kMDItemDateAdded) as? Date
    }
    
    var dateCreate: Date? {
        MDItemCopyAttribute(self, kMDItemContentCreationDate) as? Date
    }
    
    var fileName: String? {
        MDItemCopyAttribute(self, kMDItemDisplayName) as? String
    }
    
    var mimeType: UTType? {
        if let a = MDItemCopyAttribute(self, kMDItemContentType) as? String {
            return UTType(a)
        }
        
        return nil
    }
    
    var isHidden: Bool {
        return path?.FS.info.isHidden ?? false
    }
}
