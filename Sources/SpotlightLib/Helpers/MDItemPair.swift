import Foundation
import CoreSpotlight
import Essentials

public class MDItemPair {
    public let item: MDItem
    public let url: URL
    
    init?(_ item: MDItem) {
        if let path = item.path {
            self.item = item
            self.url = path.asURL()
            
            return
        }
        
        return nil
    }
}
