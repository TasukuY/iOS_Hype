//
//  HypeController.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import Foundation
import CloudKit

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
    func saveHype(with text: String, completion: @escaping (Bool) -> Void) {
        // Init a Hype object
        let newHype = Hype(body: text)
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
    
}//End of class
