//
//  User.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/4/22.
//

import Foundation
import CloudKit

struct UserStrings {
    
    //MARK: - Properties
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    static let appleUserReferenceKey = "appleUserReference"
    
}//End of struct

class User {
    
    //MARK: - Properties
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserReference: CKRecord.Reference
    
    init(username: String, bio: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserReference = appleUserReference
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
        
        self.init(username: username, bio: bio, recordID: ckRecord.recordID, appleUserReference: appleUserReference)
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
            UserStrings.appleUserReferenceKey : user.appleUserReference
        ])
    }
    
}//End of extension
