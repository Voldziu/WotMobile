//
//  Clan.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 07/01/2025.
//

import Foundation



// Structure for the API response
struct ClanOnlineMembersResponse: Decodable {
    struct Data: Decodable {
        struct Private: Decodable {
            let onlineMembers: [Int]
            
            enum CodingKeys: String, CodingKey {
                case onlineMembers = "online_members"
            }
        }
        
        let privateData: Private
        
        enum CodingKeys: String, CodingKey {
            case privateData = "private"
        }
    }
    
    let data: [String: Data]
    let status: String
}

// Function to fetch online clan members
func getOnlineClanMembers(clanId: Int, authToken: String, completion: @escaping (Result<[Int], Error>) -> Void) {
    
    let validatedToken = checkValidnessOfAuthToken(authToken: authToken, authTokenExpiresAt: AppData.AuthTokenExpiresAt)
        guard !validatedToken.isEmpty else {
            completion(.failure(NSError(domain: "AuthTokenInvalid", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid or expired authToken"])))
            return
        }
    
    
    let urlString = "https://api.worldoftanks.eu/wot/clans/info/?application_id=\(AppData.APPID)&access_token=\(authToken)&clan_id=\(clanId)&extra=private.online_members&fields=private.online_members"
    
    fetchAPIResponse(urlString: urlString, responseType: ClanOnlineMembersResponse.self) { result in
        switch result {
        case .success(let response):
            if let clanData = response.data["\(clanId)"] {
                completion(.success(clanData.privateData.onlineMembers))
            } else {
                completion(.failure(NSError(domain: "NoDataForClan", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data available for the specified clan ID."])))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}




func getOnlineClanMemberNicknames(clanId: Int, authToken: String) async -> [String] {
    var result: [String] = []
    let semaphore = DispatchSemaphore(value: 0)
    
    getOnlineClanMembers(clanId: clanId, authToken: authToken) { onlineMembersResult in
        switch onlineMembersResult {
        case .success(let onlineMemberIds):
            if onlineMemberIds.isEmpty {
                result = []
                semaphore.signal()
            } else {
                getNicknamesFromPlayerIds(playerIds: onlineMemberIds) { nicknamesResult in
                    switch nicknamesResult {
                    case .success(let nicknames):
                        result = nicknames
                        print(result)
                    case .failure(let error):
                        print("Failed to retrieve nicknames with error: \(error)")
                        result = []
                    }
                    semaphore.signal()
                }
            }
        case .failure(let error):
            print("Failed to retrieve online members with error: \(error)")
            result = []
            semaphore.signal()
        }
    }
    
    semaphore.wait()
    return result
}


