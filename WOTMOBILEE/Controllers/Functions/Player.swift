//
//  Player.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 02/01/2025.
//

import Foundation


struct Player {
    var playerInfo: PlayerInfo?
    var stats: StatsAll?
    var clan: ClanMemberInfo?
    
}

func getPlayer(playerId: Int,authToken:String? = nil) async -> Player? {
    print(playerId)
    print("getPlayer")
    var result: Player?
    let semaphore = DispatchSemaphore(value: 0)
    if(authToken != nil){
        let validatedToken = authToken.flatMap { checkValidnessOfAuthToken(authToken: $0, authTokenExpiresAt: AppData.AuthTokenExpiresAt) }
            guard let authToken = validatedToken, !authToken.isEmpty else {
                print("Invalid or expired authToken")
                return nil
            }
    }
    

    getPlayerDefinite(playerId: playerId,authToken: authToken) { completionResult in
        switch completionResult {
        case .success(let player):
            print("getPlayer2")
            print(player)
            result = player
        case .failure(let error):
            print("Failed to retrieve player with error: \(error)")
            result = nil
        }
        semaphore.signal()
    }

    semaphore.wait()
    return result
}


func getPlayerDefinite(playerId:Int,authToken:String?=nil, completion: @escaping (Result<Player, Error>) -> Void){
    if(authToken != nil){
        let validatedToken = authToken.flatMap { checkValidnessOfAuthToken(authToken: $0, authTokenExpiresAt: AppData.AuthTokenExpiresAt) }
        guard let authToken = validatedToken, !authToken.isEmpty else {
                completion(.failure(NSError(domain: "AuthTokenInvalid", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid or expired authToken"])))
                return
            }
    }
    
    
    getPlayersStatsDefinite(playerID: playerId) { result in
        switch result {
        case .success(let profileStats):
            
            getPlayerInfo(playerId: playerId,authToken: authToken) { result in
                switch result {
                case .success(let response):
                    let playerInfo = response
                    getClanMemberInfo(playerID: playerId) { result in
                        switch result {
                        case .success(let clanMemberInfo):
                            let player:Player
                            if(profileStats.battles>0){
                                
                                player = Player(playerInfo: playerInfo, stats: profileStats, clan: clanMemberInfo)
                            } else{
                                player=Player(playerInfo: nil, stats: nil,clan: nil)
                            }
                            
                            print(player)
                            completion(.success(player))
                        case .failure(let error):
                            print("Failed to fetch clan info: \(error.localizedDescription)")
                            let player=Player(playerInfo: nil, stats: nil,clan: nil)
                            completion(.success(player))
                        }
                    }
                    
                    
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    let player=Player(playerInfo: nil, stats: nil,clan: nil)  // THOSE NILS REPRESENTS VALUE: STOP PROGRESS VIEW AND INFORM THAT SEARCH HAS BEEN NOT SUCCESSFUL
                    completion(.success(player))
                }
            }
        case .failure(let error):
            print("Error retrieving profile stats: \(error.localizedDescription)")
            let player=Player(playerInfo: nil, stats: nil,clan: nil)
            completion(.success(player))
        }
    }
}

//func reduceClanInfo(clanInfoResult: ClanInfoResult) -> ClanInfoResultReduced {
//    // Check if the player is in a clan
//    if let clanInfo = clanInfoResult.clanInfo, clanInfoResult.isInClan {
//        
//        let clanInfoReduced = ClanInfoReduced(
//            clan_id: clanInfo.clan_id,
//            name: clanInfo.name,
//            tag: clanInfo.tag,
//            color: clanInfo.color,
//            emblem32URL: clanInfo.emblems.x32?.portal ?? "" // Default to empty string if URL is nil
//        )
//        
//        return ClanInfoResultReduced(
//            isInClan: true,
//            clanInfo: clanInfoReduced
//        )
//    } else {
//        // Player is not in a clan, return default values
//        return ClanInfoResultReduced(
//            isInClan: false,
//            clanInfo: ClanInfoReduced(
//                clan_id: 0,
//                name: "",
//                tag: "",
//                color: "",
//                emblem32URL: ""
//            )
//        )
//    }
//}

func getClanMemberInfo(playerID: Int, completion: @escaping (Result<ClanMemberInfo?, Error>) -> Void) {
    
    let urlString = "https://api.worldoftanks.eu/wot/clans/accountinfo/?application_id=\(AppData.APPID)&account_id=\(playerID)"

    fetchAPIResponse(urlString: urlString, responseType: ClanMemberAPIResponse.self) { result in
        switch result {
        case .success(let response):
            if let accountInfo = response.data[String(playerID)] {
                print("clanmember")
                print(accountInfo)
                completion(.success(accountInfo))
            } else {
                completion(.success(nil)) // No data for the given account ID
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}




struct PlayerNicknameResponse: Decodable {
    struct PlayerData: Decodable {
        let nickname: String
    }
    
    let data: [String: PlayerData]
    let status: String
}


func getNicknamesFromPlayerIds(playerIds: [Int], completion: @escaping (Result<[String], Error>) -> Void) {
    
    let playerIdsString = playerIds.map { "\($0)" }.joined(separator: "%2C")
    let urlString = "https://api.worldoftanks.eu/wot/account/info/?application_id=\(AppData.APPID)&account_id=\(playerIdsString)&fields=nickname"
    
    fetchAPIResponse(urlString: urlString, responseType: PlayerNicknameResponse.self) { result in
        switch result {
        case .success(let response):
            let nicknames = response.data.values.map { $0.nickname }
            completion(.success(nicknames))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
