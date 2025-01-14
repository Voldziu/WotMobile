//
//  AppData.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 02/12/2024.
//

import SwiftUI
import Combine
import Foundation


class AppData: ObservableObject {
    
    @Published var searchedPlayerName: String = "" // Zmienna globalna przechowująca nazwę wyszukiwanego gracza
    @Published var searchedPlayerID: Int = 0

    @Published var currentSubviewClan: SubviewTypeClan
    @Published var currentSubviewProfile: SubviewTypeProfile
    @Published var selectedSearchedTab = "Main"
    @Published var selectedProfileTab = "My Profile"
    @Published var selectedProfileStatsTab = "Main"
   
    
    @AppStorage("SubviewClan") var currentSubviewClanString: String = "notLogged"
    @AppStorage("SubviewProfile") var currentSubviewProfileString: String = "notLogged"
    // Przechowywanie `favorites` jako JSON w `UserDefaults` przy użyciu `@AppStorage`
    @AppStorage("favorites") private var favoritesData: String = "" // JSON encoded array
    @AppStorage("pastSearches") private var pastSearchesData: String = "" // JSON encoded array
    @AppStorage("APP-ID") static var APPID: String = "8719cbf81b872b3e89e22172fcc06d16"
    @AppStorage("ClientToken") static var AuthToken: String="" // empty if not logged
    @AppStorage("ClientID") static var loggedPlayerID: Int=0 // 0 if not logged
    @AppStorage("ClientNickname") static var loggedPlayerNickname: String="" // empty if not logged
    @AppStorage("AuthTokenExpiresAt") static var AuthTokenExpiresAt: Int=0
    @AppStorage("ClientsClanID") static var LoggedClanID: Int=0 // if 0 player not in clan
    @AppStorage("ClientsClanRank") static var LoggedClanRank: String="Reservist" // if empty player not in clan
    @AppStorage("ClanName") static var LoggedClanName: String=""
    @AppStorage("ClanTag")  static var LoggedClanTag: String=""
    @AppStorage("ClanColor") static var LoggedClanColor: String=""
    
    @Published var positionHierarchy: [String: Int] = [
            "Commander": 1,
            "Executive Officer": 2,
            "Personnel Officer": 3,
            "Combat Officer": 4,
            "Intelligence Officer": 5,
            "Quartermaster": 6,
            "Recruitment Officer": 7,
            "Junior Officer": 8,
            "Private": 9,
            "Recruit": 10,
            "Reservist": 11,
        ]
    
    
    private var cancellables = Set<AnyCancellable>()
    
    var favorites: [String] {
        get {
            if let data = favoritesData.data(using: .utf8) {
                return (try? JSONDecoder().decode([String].self, from: data)) ?? []
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                favoritesData = String(data: data, encoding: .utf8) ?? ""
            }
        }
    }
    
    // Przechowywanie `pastSearches` jako JSON w `UserDefaults`
    

    var pastSearches: [String] {
        get {
            if let data = pastSearchesData.data(using: .utf8) {
                return (try? JSONDecoder().decode([String].self, from: data)) ?? []
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                pastSearchesData = String(data: data, encoding: .utf8) ?? ""
            }
        }
    }

    // Metody do zarządzania ulubionymi i historią wyszukiwań
    func addFavorite(_ favorite: String) {
        if !favorites.contains(favorite) {
            favorites.append(favorite)
        }
    }

    func removeFavorite(_ favorite: String) {
        favorites = favorites.filter { $0 != favorite }
    }

    func addPastSearch(_ search: String) {
        if !search.isEmpty && !pastSearches.contains(search) {
            pastSearches.append(search)
        }
    }

    func removePastSearch(_ search: String) {
        pastSearches = pastSearches.filter { $0 != search }
    }
    
    init() {
            // Initialize `currentSubviewClan` and `currentSubviewProfile` using `AppStorage` values
        let clanString = UserDefaults.standard.string(forKey: "SubviewClan") ?? "notLogged"
        let profileString = UserDefaults.standard.string(forKey: "SubviewProfile") ?? "notLogged"


        self.currentSubviewClan = SubviewTypeClan(rawValue: clanString) ?? .notLogged
        self.currentSubviewProfile = SubviewTypeProfile(rawValue: profileString) ?? .notLogged



            // Observe changes in `@Published` and update `@AppStorage`
            $currentSubviewClan
                .map { $0.rawValue }
                .assign(to: \.currentSubviewClanString, on: self)
                .store(in: &cancellables)

            $currentSubviewProfile
                .map { $0.rawValue }
                .assign(to: \.currentSubviewProfileString, on: self)
                .store(in: &cancellables)
        }
    
    
  
    
    
    
}




enum SubviewTypeClan {
    case notLogged
    case notInClan
    case success
}

enum ClanPosition: String, CaseIterable {
    case commander = "Commander"
    case executiveOfficer = "Executive Officer"
    case personnelOfficer = "Personnel Officer"
    case combatOfficer = "Combat Officer"
    case intelligenceOfficer = "Intelligence Officer"
    case quartermaster = "Quartermaster"
    case recruitmentOfficer = "Recruitment Officer"
    case juniorOfficer = "Junior Officer"
    case privatePosition = "Private"
    case reservist = "Reservist"
    case recruit = "Recruit"
}


enum SubviewTypeProfile {
    case notLogged
    case success
}


extension SubviewTypeClan: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
        case "notLogged": self = .notLogged
        case "notInClan": self = .notInClan
        case "success": self = .success
        default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .notLogged: return "notLogged"
        case .notInClan: return "notInClan"
        case .success: return "success"
        }
    }
}

extension SubviewTypeProfile: RawRepresentable {
    typealias RawValue = String

    init?(rawValue: RawValue) {
        switch rawValue {
        case "notLogged": self = .notLogged
        case "success": self = .success
        default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .notLogged: return "notLogged"
        case .success: return "success"
        }
    }
}
