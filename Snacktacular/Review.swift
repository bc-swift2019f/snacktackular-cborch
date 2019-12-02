//
//  Review.swift
//  Snacktacular
//
//  Created by Carter Borchetta on 11/10/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
        
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unkown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String? ?? ""
        //let date = dictionary["date"] as! Date? ?? Date()
        let date = Date()
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) { // This confused me
        let db = Firestore.firestore()
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we have saved a record we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** Error updating document \(self.documentID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
                
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("*** Error creating new document in spot \(spot.documentID) for new review documentID \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ new document created with ref ID \(ref?.documentID ?? "Unkown")")
                    completed(true)
                }
            }
            
        }
        
    }
    
    func deleteData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete() { error in
            if let error = error {
                print("Error: deleting review with document ID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                completed(true)
            }
        }
    }
}
