//
//  Classes.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 03/12/2024.
//

import Foundation
import SwiftUI





struct Event: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    let datetimestart: Date
    let datetimeend: Date
    var participants: [String]
    var participantsID: [Int]
    let maxParticipants: Int
    let clanId: Int
    var madeById: Int
    var rank:Int // which clan position is made by
}



struct WargamingAuthResponse: Decodable { // for auth token response (login purpouses)
    let status: String
    let access_token: String
    let nickname: String
    let account_id: String
    let expires_at: String
}
