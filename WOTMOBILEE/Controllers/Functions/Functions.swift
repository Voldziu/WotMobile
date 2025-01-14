//
//  Functions.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase
import WebKit

let firebaseService = FirebaseService()

func addEvent(
    clanID:Int,
    title: String,
    datetimestart: Date,
    datetimeend: Date,
    maxParticipants: Int,
    participants: [String]=[],
    participantsID: [Int]=[],
    clanId: Int,
    madeById: Int,
    rank:Int
    
) {
    let newEvent = Event(
        title: title,
        datetimestart: datetimestart,
        datetimeend: datetimeend,
        participants: participants,
        participantsID: participantsID,
        maxParticipants: maxParticipants,
        clanId: clanId,
        madeById: madeById,
        rank:rank
    )
    
    let firebaseService = FirebaseService()
    firebaseService.addEvent(newEvent , clanID:clanID) { error in
        if let error = error {
            print("Błąd dodawania wydarzenia: \(error)")
        } else {
            print("Wydarzenie dodane pomyślnie!")
        }
    }
}




func clearCache(){
    Firestore.firestore().clearPersistence { error in
        if let error = error {
            print("Error clearing persistence: \(error)")
        } else {
            print("Persistence cleared.")
        }
    }
}

func arabicToRoman(_ number: Int) -> String {
    let romanMap: [Int: String] = [
        1: "I", 2: "II", 3: "III", 4: "IV", 5: "V",
        6: "VI", 7: "VII", 8: "VIII", 9: "IX", 10: "X"
    ]
    return romanMap[number] ?? "" 
}

func formatUnixTime(_ unixTime: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy" // Customize the date format as needed
    return dateFormatter.string(from: date)
}

func clearCookies(for domain: String) {
    let dataStore = WKWebsiteDataStore.default()
    dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        let matchingRecords = records.filter { $0.displayName.contains(domain) }
        if matchingRecords.isEmpty {
                    print("No matching cookies or data records found for domain: \(domain)")
                } else {
                    print("Matching records for \(domain):")
                    for record in matchingRecords {
                        print(" - \(record.displayName)")
                    }
                }
        
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: matchingRecords) {
            print("Cleared cookies for \(domain)")
            
        }
    }
    
    clearHTTPCookies()
}

func clearHTTPCookies() {
    let cookieStorage = HTTPCookieStorage.shared
    if let cookies = cookieStorage.cookies {
        for cookie in cookies {
            if cookie.domain.contains("worldoftanks.eu") || cookie.domain.contains("api.worldoftanks.eu") {
                cookieStorage.deleteCookie(cookie)
                print("Deleted cookie for domain: \(cookie.domain)")
            }
        }
    }
}




extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}





















