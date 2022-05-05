//
//  Hype.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import CloudKit
import UIKit

struct HypeStrings {
    
    //MARK: - Magic Strings
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let userReferenceKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
    
}//End of struct

class Hype {
    
    //MARK: - Properties
    var body: String
    var timestamp: Date
    var hypePhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    
    var ckRecordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    var photoAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(body: String, timestamp: Date = Date(), hypePhoto: UIImage? = nil, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?){
        self.body = body
        self.timestamp = timestamp
        self.ckRecordID = ckRecordID
        self.userReference = userReference
        self.hypePhoto = hypePhoto
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
        
        let userReference = ckRecord[HypeStrings.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[HypeStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Cound not transform asset to data")
            }
        }
        
        self.init(body: body, timestamp: timestamp, hypePhoto: foundPhoto, ckRecordID: ckRecord.recordID, userReference: userReference)
    }
    
}//End of extension

extension Hype: Equatable{
    static func == (lhs: Hype, rhs: Hype) -> Bool{
        return lhs.ckRecordID == rhs.ckRecordID
    }
}//End of extension

extension CKRecord {
    /**
        Packaging our Hype model properties to be stored in a CKRecord and saved to the cloud
     */
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.ckRecordID)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey : hype.body,
            HypeStrings.timestampKey : hype.timestamp,
            HypeStrings.userReferenceKey : hype.userReference,
            HypeStrings.photoAssetKey : hype.photoAsset
        ])
        
        //doing the same thing with a different methods called setValue
//        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
//        self.setValue(hype.timestamp, forKey: HypeStrings.timestampKey)
        
    }
    
}//End of extension
