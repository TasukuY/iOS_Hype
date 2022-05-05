//
//  HypeController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import CloudKit
import UIKit

class HypeController {
    
    //MARK: - Properties
    /// Shared instance
    static let shared = HypeController()
    /// Source of Truth array
    var hypes: [Hype] = []
    ///  Constant to access our publicClouldDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - CRUD funcs
    // Create
    func saveHype(with text: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { completion(false) ; return }
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        // Init a Hype object
        let newHype = Hype(body: text, hypePhoto: photo, userReference: reference)
        // Package the newHype into a CKRecord
        let hypeRecord = CKRecord(hype: newHype)
        // Saving the hypeRecord to the cloud
        publicDB.save(hypeRecord) { record, error in
            // Handling the error if there is one
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            // Unwrapping the record that was saved
            guard let record = record,
                  // Ensuring that we can init a Hype from that record
                  let savedHype = Hype(ckRecord: record)
            else { completion(false) ; return }
            // Add it to our SoT array
            print("Saved Hype successfully")
            self.hypes.insert(savedHype, at: 0)
            completion(true)
        }
    }
    
    // Fetch
    func fetchHypes(completion: @escaping (Bool) -> Void) {
        // step 3 - init the requisite predicate for the query
        let predicate = NSPredicate(value: true)
        // step 2 - Init the requisite query for the .perform methods
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        // step 1 - Perform a query on the database
        publicDB.perform(query, inZoneWith: nil) { records, error in
            // Handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            // Unwrap the found records
            guard let records = records else { completion(false) ; return }
            print("Fetched all hypes")
            // Compact map through the found records to return the non-nil Hype objects
            let fetchedHypes = records.compactMap { Hype(ckRecord: $0) }
            // Set out Sot array
            self.hypes = fetchedHypes
            completion(true)
        }
        
    }
    
    // Update
    func update(_ hype: Hype, completion: @escaping (Bool) -> Void) {
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        
        //step 3 - define the records to be updated
        let recordToUpdate = CKRecord(hype: hype)
        //step 2 - create the requisite operation
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
        //step 4 - set the properties for the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            //Handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            //Ensure that the records were returned and updated
            guard let record = records?.first else { completion(false) ; return }
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            completion(true)
        }
        //step 1 - add operation to the database
        publicDB.add(operation)
    }//End of function
    
    //Delete
    func delete(_ hype: Hype, completion: @escaping (Bool) -> Void){
        
        guard hype.userReference?.recordID == UserController.shared.currentUser?.recordID else { completion(false) ; return }
        
        //step 2 - declared operation
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [hype.ckRecordID])
        //step 3 - set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
            //handle the error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
                completion(false)
                return
            }
            
            guard let recordIDs = recordIDs else { completion(false) ; return }
            print("\(recordIDs) were removed successfully")
            completion(true)
            
        }
        //step 1 - add operation to the database
        publicDB.add(operation)
    }//End of function
    
    //MARK: - Helper Methods
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        //step 3 - Declare the requisite predicate
        let predicate = NSPredicate(value: true)
        //step 2 - Declare the subscription
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        //step 4 - Setting the subscription properties
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the Hype train"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        //step 1 - call the save(subscription) function on the database
        publicDB.save(subscription) { _, error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
        
        
    }//End of function
    
}//End of class
