//
//  PlayerSearchController.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 09/12/2024.
//

import Foundation
import SafariServices

import Foundation

// Generic API Fetcher
func fetchAPIResponse<T: Decodable>(urlString: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "NoData", code: 204, userInfo: nil)))
            return
        }

        // Convert to dictionary to check for "status"
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let status = json["status"] as? String, status != "ok" {
                    print(urlString)
                    print(json)
                    completion(.failure(NSError(domain: "InvalidStatus", code: 400, userInfo: [NSLocalizedDescriptionKey: "Status is not 'ok'"])))
                    return
                }
            } else {
                completion(.failure(NSError(domain: "InvalidJSON", code: 422, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON"])))
                return
            }
        } catch {
            completion(.failure(NSError(domain: "InvalidJSON", code: 422, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON: \(error.localizedDescription)"])))
            return
        }

        // Proceed with decoding if status is "ok"
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            completion(.success(decodedResponse))
        } catch {
            print("Decoding error: \(error)")
            print(urlString)
            completion(.failure(error))
        }
    }

    task.resume()
}



// Models for API Response
struct SearchPlayerResponse: Decodable {
    let status: String
    let meta: Meta
    let data: [Player]

    struct Meta: Decodable {
        let count: Int
    }

    struct Player: Decodable {
        let nickname: String
        let account_id: Int
    }
}

// SearchPlayer Function
func searchPlayer(nickname: String, completion: @escaping (Result<Int, Error>) -> Void) {
    let urlString = "https://api.worldoftanks.eu/wot/account/list/?application_id=\(AppData.APPID)&type=exact&&search=\(nickname)"

    fetchAPIResponse(urlString: urlString, responseType: SearchPlayerResponse.self) { result in
        switch result {
        case .success(let response):
            guard response.status == "ok", response.meta.count > 0 else {
                completion(.failure(NSError(domain: "PlayerNotFound", code: 404, userInfo: nil)))
                return
            }

            if let firstPlayer = response.data.first {
                completion(.success(firstPlayer.account_id))
            } else {
                completion(.failure(NSError(domain: "NoPlayers", code: 404, userInfo: nil)))
            }

        case .failure(let error):
            completion(.failure(error))
        }
    }
}



struct PlayerInfoResponse: Decodable {
    let status: String
    let meta: Meta
    let data: [String: PlayerInfo]
    
    struct Meta: Decodable {
        let count: Int
    }
    
    
}

struct PlayerInfo: Decodable {
    let account_id: Int
    let nickname: String
    let global_rating: Int
    let created_at: Int
    let updated_at: Int
    let statistics: Statistics
    let privateData: PrivateData?
    let clan_id: Int?
    
    enum CodingKeys: String, CodingKey {
             // Map the "private" JSON key to `privateData`
            case account_id
            case nickname
            case global_rating
            case created_at
            case updated_at
            case statistics
            case privateData = "private" // Map "private" JSON key to `privateData`
            case clan_id
        }
    
//    init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            privateData = try container.decodeIfPresent(PrivateData.self, forKey: .privateData)
//        }
    
    struct Statistics: Decodable {
        let all: DetailedStats
        
        
    }
    
    struct PrivateData: Decodable {
            let restrictions: Restrictions
            let gold: Int
            let free_xp: Int
            let ban_time: Int?
            let is_bound_to_phone: Bool
            let is_premium: Bool
            let credits: Int
            let premium_expires_at: Int
            let bonds: Int
            let battle_life_time: Int
            let ban_info: String?
            
            struct Restrictions: Decodable {
                let chat_ban_time: Int?
            }
        }
}




func getPlayerInfo(playerId: Int, authToken: String? = nil, completion: @escaping (Result<PlayerInfo, Error>) -> Void) {
    // Construct the base URL
    var urlString = "https://api.worldoftanks.eu/wot/account/info/?application_id=\(AppData.APPID)&account_id=\(playerId)"
    print(urlString)
    // Add the auth token to the URL if provided
    if let token = authToken {
        urlString += "&access_token=\(token)"
    }
//    https://api.worldoftanks.eu/wot/account/info/?application_id=8719cbf81b872b3e89e22172fcc06d16&account_id=507211631&access_token=c1ea89f9637ca69f792def3367df5cd51cfd23db
//    https://api.worldoftanks.eu/wot/account/info/?application_id=5336bdd4e0de7a8b3581103037a7e1b7&account_id=507211631&access_token=c1ea89f9637ca69f792def3367df5cd51cfd23db
    
    // Use the abstract function to fetch the data
    fetchAPIResponse(urlString: urlString, responseType: PlayerInfoResponse.self) { result in
            switch result {
            case .success(let response):
                // Check the status and ensure data exists
                guard response.status == "ok", let playerData = response.data[String(playerId)] else {
                    completion(.failure(NSError(domain: "PlayerNotFound", code: 404, userInfo: nil)))
                    return
                }

                // Pass the player data to the completion handler
                completion(.success(playerData))

            case .failure(let error):
                // Pass the error to the completion handler
                completion(.failure(error))
            }
        }
}



struct ClanInfoResponse: Decodable {
    let status: String
    let meta: Meta
    let data: [String: ClanInfo]
    
    struct Meta: Decodable {
        let count: Int
    }
    
    struct ClanInfo: Decodable {
        let clan_id: Int
        let name: String
        let tag: String
        let leader_id: Int
        let leader_name: String
        let members_count: Int
        let description: String?
        let motto: String?
        let created_at: Int
        let updated_at: Int
        let emblems: Emblems
        let members: [Member]
        let color: String
        
        struct Emblems: Decodable {
                let x32: ImageURLs?
                let x64: ImageURLs?
                let x256: ImageURLs?
                let x24: ImageURLs?
                let x195: ImageURLs?

                struct ImageURLs: Decodable {
                    let portal: String?
                    let wowp: String?
                    let wot: String?
                }
            }
        
        struct Member: Decodable {
            let role: String
            let role_i18n: String
            let joined_at: Int
            let account_id: Int
            let account_name: String
        }
    }
}


struct ClanMemberAPIResponse: Decodable {
    let status: String
    let meta: Meta
    let data: [String: ClanMemberInfo?]
    struct Meta: Decodable {
        let count: Int
    }
}



struct ClanMemberInfo: Decodable {
    let clan: Clan?
    let accountID: Int
    let roleI18n: String
    let joinedAt: Int
    let role: String
    let accountName: String

    enum CodingKeys: String, CodingKey {
        case clan
        case accountID = "account_id"
        case roleI18n = "role_i18n"
        case joinedAt = "joined_at"
        case role
        case accountName = "account_name"
    }
}

struct Clan: Decodable {
    let membersCount: Int
    let name: String
    let color: String
    let createdAt: Int
    let tag: String
    let emblems: Emblems
    let clanID: Int

    enum CodingKeys: String, CodingKey {
        case membersCount = "members_count"
        case name
        case color
        case createdAt = "created_at"
        case tag
        case emblems
        case clanID = "clan_id"
    }
}

struct Emblems: Decodable {
    let x32: EmblemURL

    struct EmblemURL: Decodable {
        let portal: String?
       
    }
}



struct ClanInfoResult {
    let isInClan: Bool
    let clanInfo: ClanInfoResponse.ClanInfo?
}




func getClanInfo(playerId: Int, authToken: String? = nil, completion: @escaping (Result<ClanInfoResult, Error>) -> Void) {
    // Fetch player info to get the clan ID
    
    getPlayerInfo(playerId: playerId) { result in
        switch result {
        case .success(let playerInfo):
            // Sprawdź, czy gracz ma przypisany `clanID`
            guard let clanID = playerInfo.clan_id else {
                // Zwracamy informację, że gracz nie jest w klanie
                let noClanResult = ClanInfoResult(isInClan: false, clanInfo: nil)
                completion(.success(noClanResult))
                return
            }
            
            // Fetch clan info using the clan ID
            let urlString = "https://api.worldoftanks.eu/wot/clans/info/?application_id=\(AppData.APPID)&clan_id=\(clanID)"
            fetchAPIResponse(urlString: urlString, responseType: ClanInfoResponse.self) { clanResult in
                switch clanResult {
                case .success(let clanResponse):
                    if let clanInfo = clanResponse.data["\(clanID)"] {
                        let inClanResult = ClanInfoResult(isInClan: true, clanInfo: clanInfo)
                        completion(.success(inClanResult))
                    } else {
                        completion(.failure(NSError(domain: "InvalidClanID", code: 404, userInfo: [NSLocalizedDescriptionKey: "Clan ID not found in response."])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
import Foundation

// MARK: - Root Structure
struct TankIDResponse: Codable {
    let status: String
    let meta: MetaID
    let data: [String: [TankID]]
}

// MARK: - Meta Structure
struct MetaID: Codable {
    let count: Int
}

// MARK: - TankID Structure
struct TankID: Codable {
    let tank_id: Int
}
struct TankIDResponseAll: Codable {
   let status: String
   let meta: MetaIDALL
   let data: [String: TankID]
}

// MARK: - Meta Structure
struct MetaIDALL: Codable {
   let count: Int
}

// MARK: - TankID Structure
struct TankIDALL: Codable {
   let tank_id: Int
}
               

func getTankIDs(accountId: Int, completion: @escaping (Result<[Int], Error>) -> Void) {
    // Construct the URL for fetching tank stats
    let urlString = "https://api.worldoftanks.eu/wot/account/tanks/?application_id=\(AppData.APPID)&account_id=\(accountId)"
    
    // Fetch data from the API
    fetchAPIResponse(urlString: urlString, responseType: TankIDResponse.self) { result in
        switch result {
        case .success(let tankIDResponse):
            // Extract tank IDs for the given account ID
            if let tankData = tankIDResponse.data["\(accountId)"] {
                let tankIDs = tankData.map { $0.tank_id }
                completion(.success(tankIDs))
            } else {
                completion(.failure(NSError(domain: "InvalidAccountID", code: 404, userInfo: [NSLocalizedDescriptionKey: "Account ID not found in response."])))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

func fetchAllTankIDs(completion: @escaping (Result<[Int], Error>) -> Void) {
    let baseURL = "https://api.worldoftanks.eu/wot/encyclopedia/vehicles/"
    
    let fields = "tank_id"
    
    // Pagination variables
    let limit = 100
    var page = 1
    var allTankIDs: [Int] = []
    
    func fetchPage() {
        let urlString = "\(baseURL)?application_id=\(AppData.APPID)&fields=\(fields)&limit=\(limit)&page=\(page)"
        fetchAPIResponse(urlString: urlString, responseType: TankIDResponseAll.self) { result in
            switch result {
            case .success(let response):
                guard response.status == "ok" else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: 400, userInfo: [NSLocalizedDescriptionKey: "API response status is not 'ok'."])))
                    return
                }
                
                // Collect tank IDs from the current page
                allTankIDs.append(contentsOf: response.data.values.map { $0.tank_id })
                
                // Check if more pages are available
                if response.data.count == limit {
                    page += 1
                    fetchPage() // Fetch the next page
                } else {
                    completion(.success(allTankIDs)) // All pages fetched
                }
                
            case .failure(let error):
                completion(.failure(error)) // Pass the error
            }
        }
    }
    
    fetchPage() // Start fetching from the first page
}




struct TankStatsResponse: Codable {
    let status: String
    let meta: Meta
    let data: [String: [TankData]]
}

// MARK: - Meta Structure
struct Meta: Codable {
    let count: Int
}

// MARK: - Tank Stats Structure
struct TankData: Codable {
    let all: DetailedStats
    var tank_id: Int
}

// MARK: - Detailed Stats Structure
struct DetailedStats: Codable {
    
    let spotted: Int
    let battles_on_stunning_vehicles: Int
    let track_assisted_damage: Int
    let avg_damage_blocked: Double
    let capture_points: Int
    let explosion_hits: Int
    let piercings: Int
    let xp: Int
    let avg_damage_assisted: Double
    let dropped_capture_points: Int
    let damage_dealt: Int
    let hits_percents: Int
    let draws: Int
    let tanking_factor: Double
    let battles: Int
    let damage_received: Int
    let survived_battles: Int
    let frags: Int
    let stun_number: Int
    let avg_damage_assisted_radio: Double
    let direct_hits_received: Int
    let radio_assisted_damage: Int
    let stun_assisted_damage: Int
    let hits: Int
    let battle_avg_xp: Int
    let wins: Int
    let losses: Int
    let piercings_received: Int
    let no_damage_direct_hits_received: Int
    let shots: Int
    let explosion_hits_received: Int
    let avg_damage_assisted_stun: Double
    let avg_damage_assisted_track: Double
}




func getTanksStats(accountId: Int, tankIDs: [Int], completion: @escaping (Result<[TankData], Error>) -> Void) {
    // Convert tankIDs array to a comma-separated string
    let tankIDsString = tankIDs.map { String($0) }.joined(separator: ",")
    
    // Construct the URL for fetching tank stats
    let urlString = "https://api.worldoftanks.eu/wot/tanks/stats/?application_id=\(AppData.APPID)&account_id=\(accountId)&fields=all,tank_id&tank_id=\(tankIDsString)"
    print(urlString)
    
    // Fetch data from the API
    fetchAPIResponse(urlString: urlString, responseType: TankStatsResponse.self) { result in
        switch result {
        case .success(let tankStatsResponse):
            // Extract tank data for the given account ID
            if let tankStatsArray = tankStatsResponse.data["\(accountId)"] {
                // Ensure the number of tankStats matches the number of tankIDs
                guard tankStatsArray.count == tankIDs.count else {
                    completion(.failure(NSError(domain: "TankIDMismatch", code: 500, userInfo: [NSLocalizedDescriptionKey: "The number of stats returned does not match the number of tank IDs provided."])))
                    return
                }
                
            
                
                
                completion(.success(tankStatsArray))
            } else {
                completion(.failure(NSError(domain: "InvalidAccountID", code: 404, userInfo: [NSLocalizedDescriptionKey: "Account ID not found in response."])))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}


struct WN8ExpectedData: Decodable {
    let IDNum: Int
    let expDamage: Double
    let expDef: Double
    let expFrag: Double
    let expSpot: Double
    let expWinRate: Double
}

struct WN8ExpectedResponse: Decodable {
    let data: [WN8ExpectedData]
}

func fetchWN8ExpectedData(tanksIDs: [Int], completion: @escaping (Result<[WN8ExpectedData], Error>) -> Void) {
    // Static URL for the WN8 expected data
    let urlString = "https://static.modxvm.com/wn8-data-exp/json/wg/wn8exp.json"
    print("Fetching WN8 Expected Data from: \(urlString)")
    
    // Fetch data using the provided fetchAPIResponse function
    fetchAPIResponse(urlString: urlString, responseType: WN8ExpectedResponse.self) { result in
        switch result {
        case .success(let response):
            // Filter the data based on tanksIDs
            let filteredData = response.data.filter { tanksIDs.contains($0.IDNum) }
            completion(.success(filteredData))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}









func loginWargaming(completion: @escaping (Result<WargamingAuthResponse, Error>) -> Void) {
    let oauthHandler = OAuthHandler()
    oauthHandler.startAuthentication { result in
        switch result {
        case .success(let wargamingAuthResponse):
            completion(.success(wargamingAuthResponse))
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
}










