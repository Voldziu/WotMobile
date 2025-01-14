import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    private let db = Firestore.firestore()

    func addEvent(_ event: Event, clanID: Int, completion: @escaping (Error?) -> Void) {
        do {
            let eventData = try Firestore.Encoder().encode(event)
            db.collection("clans").document(String(clanID)).collection("events").document(event.id).setData(eventData) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func fetchEvents(clanID: Int, completion: @escaping ([Event]?, Error?) -> Void) {
            db.collection("clans").document(String(clanID)).collection("events").addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion(nil, error)
                    return
                }
                let now = Date()
                let events = documents.compactMap { doc -> Event? in
                    if let eventEndDate = (doc.data()["datetimeend"] as? Timestamp)?.dateValue(), eventEndDate > now {
                        return try? doc.data(as: Event.self)
                    }
                    return nil
                }
                completion(events, nil)
            }
        }

    func deleteEvent(clanID: Int, eventID: String, completion: @escaping (Error?) -> Void) {
        db.collection("clans").document(String(clanID)).collection("events").document(eventID).delete { error in
            completion(error)
        }
    }

    func updateEvent(_ event: Event, clanID: Int, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("clans").document(String(clanID)).collection("events").document(event.id).setData(from: event, merge: true) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func joinEvent(clanID: Int, eventID: String, playerNickname: String, playerID: Int, completion: @escaping (Error?) -> Void) {
        let eventRef = db.collection("clans").document(String(clanID)).collection("events").document(eventID)

        eventRef.updateData([
            "participantsID": FieldValue.arrayUnion([playerID]),
            "participants": FieldValue.arrayUnion([playerNickname])
        ]) { error in
            completion(error)
        }
    }

    func leaveEvent(clanID: Int, eventID: String, playerNickname: String, playerID: Int, completion: @escaping (Error?) -> Void) {
        let eventRef = db.collection("clans").document(String(clanID)).collection("events").document(eventID)

        eventRef.updateData([
            "participantsID": FieldValue.arrayRemove([playerID]),
            "participants": FieldValue.arrayRemove([playerNickname])
        ]) { error in
            completion(error)
        }
    }
}

func signInAnonymously() {
    Auth.auth().signInAnonymously { result, error in
        if let error = error {
            print("Anonymous auth failed: \(error.localizedDescription)")
        } else {
            print("Signed in anonymously: \(result?.user.uid ?? "")")
        }
    }
}



func checkValidnessOfAuthToken(authToken: String,authTokenExpiresAt:Int) -> String {
    // Retrieve the current Unix timestamp
    let currentTime = Int(Date().timeIntervalSince1970)
    
    // Compare the current time with the AuthToken
    if currentTime >= authTokenExpiresAt {
        print("AuthToken has expired")
       
        return ""
    } else {
        print("AuthToken is valid")
        return authToken
    }
}
    
    

