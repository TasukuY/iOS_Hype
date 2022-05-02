//
//  Hype.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import Foundation
import CloudKit

struct HypeStrings {
    
    //MARK: - Magic Strings
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    
    //MARK: - Properties
    var body: String
    var timestamp: Date
    
    init(body: String, timestamp: Date = Date()){
        self.body = body
        self.timestamp = timestamp
    }
    
}//End of class

extension Hype {
    /**
        Taking a CKRecored and pulling out the values found to initialize out Hype model
    */
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date
        else { return nil }
        
        self.init(body: body, timestamp: timestamp)
    }
    
}//End of extension

extension CKRecord {
    /**
        Packaging our Hype model properties to be stored in a CKRecord and saved to the cloud
     */
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
        
        //doing the same thing with a different methods called setValue
//        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
//        self.setValue(hype.timestamp, forKey: HypeStrings.timestampKey)
        
    }
    
}//End of extension
