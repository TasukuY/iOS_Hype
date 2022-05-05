//
//  UserController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/4/22.
//

import UIKit
import CloudKit

class UserController {
    
    //MARK: - Properties
    static let shared = UserController()
    var currentUser: User? //SoT
    //Database constant
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - CRUD funcs
    func createUser(with username: String, bio: String, profilePhoto: UIImage?, completion: @escaping (Bool) -> Void) {
        //Fetching the CKUserIdentity recordID, creating a reference to use with our User object
        fetchAppleUserReference { reference in
            //Ensure that we can unwrap the reference
            guard let reference = reference else { completion(false) ; return }
            //Init a newUser with the reference
            let newUser = User(username: username, bio: bio, profilePhoto: profilePhoto, appleUserReference: reference)
            //Create the CKRecord to be saved from the newUser
            let record = CKRecord(user: newUser)
            //Call the .save method to save the newly created CKRecord
            self.publicDB.save(record) { record, error in
                //Handle the error
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                    completion(false)
                    return
                }
                //Unwrap the record that was saved, ensure that we can init a user from that record
                guard let record = record,
                      let savedUser = User(ckRecord: record)
                else { completion(false) ; return }
                //set the currentUser and complete true
                self.currentUser = savedUser
                print("Created User: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
        
    }//End of function
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        //step 4 - Fetch and unwrap appleUserRef to use in our predicate
        fetchAppleUserReference { reference in
            guard let reference = reference else { completion(false) ; return }
            //step 3 - Define the predicate
            //This predicate takes an array of arguments and passes them into the format, the first item in the array is being passed to the %K(Key), and the second item in the array is being passes into the %@(Value)
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey, reference])
            //step 2 - Init the query
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            //step 1 - perform the query
            self.publicDB.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                    completion(false)
                    return
                }
                
                guard let record = records?.first,
                      let foundUser = User(ckRecord: record)
                else { completion(false) ; return }
                
                self.currentUser = foundUser
                print("Fetched User: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
        
    }//End of function
    
    func update() {
        
    }
    
    func delete() {
        
    }
    
    //MARK: - Helper Methods
    private func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        
        CKContainer.default().fetchUserRecordID { recordID, error in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(nil)
                return
            }
            
            guard let recordID = recordID else { completion(nil) ; return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
        
    }//End of function
    
}//End of class
