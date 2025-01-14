//
//  Tanks.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation


struct Tank:Identifiable,Equatable{
    let id=UUID()
    //let tankImagesDirectories: TankImagesDirectories
    let basicStats: TankBasicInfo
    let stats: TankStats
    
    static func == (lhs: Tank, rhs: Tank) -> Bool {
            lhs.id == rhs.id
        }
}




struct TankImagesResponse: Decodable {
    let status: String
    let data: [String: TankDataImages]
    let meta: TankMeta
}

struct TankMeta: Decodable {
    let count: Int
    let page_total: Int
    let total: Int
    let limit: Int
    let page: Int? // "page" can be null, so it should be optional
}

struct TankDataImages: Decodable {
    let images: TankImagesUrls
}

struct TankImagesUrls: Decodable {
    let contour_icon: String
    let big_icon: String
}
//struct TankImagesDirectories:Decodable{
//    let contour_icon_directory:URL
//    let big_icon_directory:URL
//}

struct BasicTankInfoResponse: Decodable {
    let status: String
    let data: [String: TankBasicInfo?]
}

struct TankBasicInfo: Decodable {
    let tier: Int
    let type: String
    let short_name: String
    let nation: String
    let tank_id:Int
}


func getTanks(playerId: Int) async-> [Tank]? {
    var result: [Tank]?
    let semaphore = DispatchSemaphore(value: 0)
    
    getTanksForPlayer(playerId: playerId) { completionResult in
        switch completionResult {
        case .success(let tanks):
            print("Successfully retrieved tanks:")
            for tank in tanks {
                print("Tank Name: \(tank.basicStats.short_name)")
                print("Nation: \(tank.basicStats.nation)")
                print("Type: \(tank.basicStats.type)")
                print("Tier: \(tank.basicStats.tier)")
                print("---------------------------------")
            }
            result = tanks
        case .failure(let error):
            print("Failed to retrieve tanks with error: \(error)")
            result = []
        }
        semaphore.signal()
    }

    semaphore.wait() 
    return result
}



func getTanksForPlayer(playerId: Int, completion: @escaping (Result<[Tank], Error>) -> Void) {
    


    
    getPlayersTanksStatsDefinite(playerID: playerId) { result in
        switch result {
        case .success(let listTanksStats):
            getPlayersTanksIds(accountID: playerId) { result in
                switch result {
                case .success(let tankIds):
                    getBasicTanksInfo(tankIds: tankIds) { result in
                        switch result {
                        case .success(let tankInfos):
                            // Ensure tankInfos and listTanksStats are aligned
                            guard tankInfos.count == listTanksStats.count else {
                                print("Mismatched data: Basic info count (\(tankInfos.count)) does not match stats count (\(listTanksStats.count))")
                                completion(.failure(NSError(domain: "MismatchedData", code: 1, userInfo: nil)))
                                return
                            }

                            // Combine basic info and stats
                            let basicInfoDict = Dictionary(uniqueKeysWithValues: tankInfos.map { ($0.tank_id, $0) })
                            let statsDict = Dictionary(uniqueKeysWithValues: listTanksStats.map { ($0.tank_id, $0) })

                            var tanks: [Tank] = []

                            for (tank_id, basicStats) in basicInfoDict {
                                if let stats = statsDict[tank_id] {
                                    
                                    let tank = Tank(
                                        
                                        basicStats: basicStats,
                                        stats: stats
                                    )
                                    tanks.append(tank)
                                }
                            }
                            completion(.success(tanks))
                            
                        case .failure(let error):
                            print("Error fetching tank info: \(error)")
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    print("Error fetching player tank IDs: \(error)")
                    completion(.failure(error))
                }
            }
            
        case .failure(let error):
            print("Failed to retrieve tank stats with error: \(error)")
            completion(.failure(error))
        }
    }
}



func fetchTankImagesUrlsAll(tankIds: [Int], completion: @escaping (Result<[[Int: [String]]], Error>) -> Void) {
    // Split tankIds into chunks of max 100
    let chunkedTankIDs = stride(from: 0, to: tankIds.count, by: 100).map {
        Array(tankIds[$0..<min($0 + 100, tankIds.count)])
    }

    // Prepare to collect results
    var allTankImages: [[Int: [String]]] = []
    let dispatchGroup = DispatchGroup()
    var fetchError: Error?

    // Fetch images for each chunk
    for chunk in chunkedTankIDs {
        dispatchGroup.enter()
        fetchTankImagesURLsMax100(tankIds: chunk) { result in
            switch result {
            case .success(let tankImages):
                allTankImages.append(contentsOf: tankImages)
            case .failure(let error):
                print("Error fetching images for chunk \(chunk): \(error.localizedDescription)")
                fetchError = error
            }
            dispatchGroup.leave()
        }
    }

    // Notify when all requests are completed
    dispatchGroup.notify(queue: .main) {
        if let error = fetchError {
            completion(.failure(error))
        } else {
            completion(.success(allTankImages))
        }
    }
}

func fetchTankImagesURLsMax100(tankIds: [Int], completion: @escaping (Result<[[Int: [String]]], Error>) -> Void) {
    // Construct the URL with tankIds
    let tankIdsString = tankIds.map(String.init).joined(separator: ",")
    let urlString = "https://api.worldoftanks.eu/wot/encyclopedia/vehicles/?application_id=\(AppData.APPID)&tank_id=\(tankIdsString)&fields=images"
    
    // Fetch API response
    fetchAPIResponse(urlString: urlString, responseType: TankImagesResponse.self) { result in
        switch result {
        case .success(let response):
            guard response.status == "ok" else {
                completion(.failure(NSError(domain: "InvalidResponse", code: 400, userInfo: nil)))
                return
            }

            // Prepare the result as a list of dictionaries
            let imageList = response.data.compactMap { tankId, tankData in
                if let intTankId = Int(tankId) {
                    // Replace "http" with "https" in the URLs
                    let contourIcon = tankData.images.contour_icon.replacingOccurrences(of: "http://", with: "https://")
                    let bigIcon = tankData.images.big_icon.replacingOccurrences(of: "http://", with: "https://")
                    
                    return [intTankId: [contourIcon, bigIcon]]
                }
                return nil
            }


            completion(.success(imageList))

        case .failure(let error):
            completion(.failure(error))
        }
    }
}


func getBasicTanksInfo(tankIds: [Int], completion: @escaping (Result<[TankBasicInfo], Error>) -> Void) {
    let chunkedTankIDs = stride(from: 0, to: tankIds.count, by: 100).map {
        Array(tankIds[$0..<min($0 + 100, tankIds.count)])
    }
    
    var allTankInfos: [TankBasicInfo] = []
    let dispatchGroup = DispatchGroup()
    var fetchError: Error?
    
    for chunk in chunkedTankIDs {
        dispatchGroup.enter()
        getBasicTanksInfoMax100(tankIds: chunk) { result in
            switch result {
            case .success(let tankInfos):
                allTankInfos.append(contentsOf: tankInfos)
            case .failure(let error):
                print("Error fetching tanks info for chunk \(chunk): \(error)")
                fetchError = error
            }
            dispatchGroup.leave()
        }
    }
    
    dispatchGroup.notify(queue: .main) {
        if let error = fetchError {
            completion(.failure(error))
        } else {
            completion(.success(allTankInfos))
        }
    }
}



func getBasicTanksInfoMax100(tankIds: [Int], completion: @escaping (Result<[TankBasicInfo], Error>) -> Void) {
    let tankIdsString = tankIds.map(String.init).joined(separator: ",")
    let urlString = "https://api.worldoftanks.eu/wot/encyclopedia/vehicles/?application_id=\(AppData.APPID)&tank_id=\(tankIdsString)&fields=short_name,nation,type,tier,tank_id"
    print("max100")
    print(urlString)
    
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
        
        do {
            let decodedResponse = try JSONDecoder().decode(BasicTankInfoResponse.self, from: data)
            let tankInfos = decodedResponse.data.compactMap { _, info in info }
            completion(.success(tankInfos))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}












