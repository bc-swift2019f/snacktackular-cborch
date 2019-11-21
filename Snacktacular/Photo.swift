//
//  Photo.swift
//  Snacktacular
//
//  Created by Carter Borchetta on 11/10/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
    var documentUUID: String
    
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "Unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) { // This confused me
        let db = Firestore.firestore()
        let storage = Storage.storage()
        // convert photo.image to a data type so it can be saved by firebase storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("Error: could not convert image to data format")
            return completed(false)
        }
        documentUUID = UUID().uuidString // generate a unique id to use for the photo images name
        // create a ref to upload storage to spot.documentID's folder (bucket), with the name we created
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success) { (snapshot) in
            // Create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            // This will either create a new doc at document UUID or update the existing doc with that name
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** Error updating document \(self.documentUUID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
                
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("Error: upload task for file \(self.documentUUID) failed, in spot \(spot.documentID)")
            }
            return completed(false)
        }
        
    }
    
}
