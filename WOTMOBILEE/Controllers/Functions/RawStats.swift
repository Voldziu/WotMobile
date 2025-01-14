//
//  RawStats.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation

func getPlayersTanksIds(accountID: Int, completion: @escaping (Result<[Int], Error>) -> Void) {
    getTankIDs(accountId: accountID) { result in
        switch result {
        case .success(let tankIDs):
            // Remove tank ID 16913 if it exists
            let filteredTankIDs = tankIDs.filter { $0 != 16913 } // I dont care if its not good. WT auf E100 is not well handled in api. DOnt care
            
            // Return the filtered list
            completion(.success(filteredTankIDs))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}



func getPlayersStats(accountID: Int, completion: @escaping (Result<[TankData], Error>) -> Void) {
    getPlayersTanksIds(accountID: accountID) { result in
        switch result {
        case .success(let tankIDs):
            print("Tank IDs retrieved: \(tankIDs)")
            
            
            
            let chunkedTankIDs = stride(from: 0, to: tankIDs.count, by: 100).map {
                Array(tankIDs[$0..<min($0 + 100, tankIDs.count)])
            }
            // Process each sublist of tank IDs
            var allTankStats: [TankData] = []
            let dispatchGroup = DispatchGroup()
            var fetchError: Error?

            for chunk in chunkedTankIDs {
                dispatchGroup.enter()
                getTanksStats(accountId: accountID, tankIDs: chunk) { result in
                    switch result {
                    case .success(let tankStats):
                        allTankStats.append(contentsOf: tankStats)
                    case .failure(let error):
                        print("Error fetching stats for chunk \(chunk): \(error.localizedDescription)")
                        fetchError = error
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Wait for all requests to complete
            dispatchGroup.notify(queue: .main) {
                if let error = fetchError {
                    completion(.failure(error))
                } else {
                    completion(.success(allTankStats))
                }
            }
            
        case .failure(let error):
            completion(.failure(error))
        }
    }
}




