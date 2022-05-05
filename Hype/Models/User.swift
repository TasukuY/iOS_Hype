//
//  User.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/4/22.
//

import UIKit
import CloudKit

struct UserStrings {
    
    //MARK: - Properties
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserReferenceKey = "appleUserReference"
    fileprivate static let photoAssetKey = "photoAsset"
    
}//End of struct

class User {
    
    //MARK: - Properties
    //Class Properties
    var username: String
    var bio: String
    var profilePhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            self.photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    //CloudKit Properties
    var recordID: CKRecord.ID
    var appleUserReference: CKRecord.Reference
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
    
    init(username: String, bio: String = "", profilePhoto: UIImage? = nil, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
    
}//End of class

extension User {
    /**
        Taking a CKRecored and pulling out the values found to initialize out Hype model
    */
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
              let appleUserReference = ckRecord[UserStrings.appleUserReferenceKey] as? CKRecord.Reference,
              let bio = ckRecord[UserStrings.bioKey] as? String
        else { return nil }
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform the asset to data")
            }
        }
        
        self.init(username: username, bio: bio, profilePhoto: foundPhoto, recordID: ckRecord.recordID, appleUserReference: appleUserReference)
    }
    
}//End of extension

extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool{
        return lhs.recordID == rhs.recordID
    }
}//End of extension

extension CKRecord {
    /**
        Packaging our Hype model properties to be stored in a CKRecord and saved to the cloud
     */
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        
        self.setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserReferenceKey : user.appleUserReference,
            UserStrings.photoAssetKey : user.photoAsset
        ])
    }
    
}//End of extension
