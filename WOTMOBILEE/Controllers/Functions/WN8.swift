//
//  WN8.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation


func getAverageValuesAll(listTankData:[TankData])->[TankActualDataAvg]{
    var list:[TankActualDataAvg] = []
    
    
    for tank in listTankData{
        //print(tank)
        list.append(getAverageValues(tankData: tank))
    }
    
    
    return list
    
}

struct TankActualDataAvg {
    let tank_id:Int
    let averageFrags: Double
    let averageWins: Double
    let averageSpotted: Double
    let averageDefense: Double
    let averageDamage: Double
    
    let battles:Int
}

func getAverageValues(tankData: TankData) -> TankActualDataAvg {
    let tank_id = tankData.tank_id
    let battles = max(tankData.all.battles, 1) // Prevent division by zero
    let averageFrags = Double(tankData.all.frags) / Double(battles)
    let averageWins = 100 *  Double(tankData.all.wins) / Double(battles)
    let averageSpotted = Double(tankData.all.spotted) / Double(battles)
    let averageDefense = Double(tankData.all.dropped_capture_points) / Double(battles)
    let averageDamage = Double(tankData.all.damage_dealt) / Double(battles)

    let tank = TankActualDataAvg(
        tank_id: tank_id,
        averageFrags: averageFrags,
        averageWins: averageWins,
        averageSpotted: averageSpotted,
        averageDefense: averageDefense,
        averageDamage: averageDamage,
        battles:battles
    )
   // print(tank)
    return tank
}

func calculateTankWn8(expectedData: WN8ExpectedData,actualData:TankActualDataAvg)->Int{
    let rDAMAGE = actualData.averageDamage / expectedData.expDamage
    let rSPOT = actualData.averageSpotted / expectedData.expSpot
    let rFRAG = actualData.averageFrags / expectedData.expFrag
    let rDEF = actualData.averageDefense / expectedData.expDef
    let rWIN = actualData.averageWins / expectedData.expWinRate
//    print("Tank ID: \(actualData.tank_id)")
//    print("Average Damage: \(actualData.averageDamage), Expected Damage: \(expectedData.expDamage)")
//    print("Average Frags: \(actualData.averageFrags), Expected Frags: \(expectedData.expFrag)")
//    print("Average Wins: \(actualData.averageWins), Expected Wins: \(expectedData.expWinRate)")
//    print("Average Spotted: \(actualData.averageSpotted), Expected Spotted: \(expectedData.expSpot)")
//    print("Average Defense: \(actualData.averageDefense), Expected Defense: \(expectedData.expDef)")
//    print("Battles: \(actualData.battles)")
    
    let rWINc = max(0, (rWIN - 0.71) / (1 - 0.71))
    let rDAMAGEc = max(0, (rDAMAGE - 0.22) / (1 - 0.22))
    let rFRAGc = max(0, min(rDAMAGEc + 0.2, (rFRAG - 0.12) / (1 - 0.12)))
    let rSPOTc = max(0, min(rDAMAGEc + 0.1, (rSPOT - 0.38) / (1 - 0.38)))
    let rDEFc = max(0, min(rDAMAGEc + 0.1, (rDEF - 0.10) / (1 - 0.10)))
    
    let wn8 = 980 * rDAMAGEc +
                  210 * rDAMAGEc * rFRAGc +
                  155 * rFRAGc * rSPOTc +
                  75 * rDEFc * rFRAGc +
                  145 * min(1.8, rWINc)
    
        
    return Int(round(wn8))
    
    
}

func calculateOverallWn8(listExpectedData: [WN8ExpectedData], listActualData: [TankActualDataAvg]) -> Int {
    guard !listExpectedData.isEmpty && !listActualData.isEmpty else {
        print("Error: One or both lists are empty")
        return 0
    }
    
    // Create a dictionary for fast lookup of WN8ExpectedData by IDnum
    let expectedDataDict = Dictionary(uniqueKeysWithValues: listExpectedData.map { ($0.IDNum, $0) })
    
    var sumTotalWN8: Int = 0
    var totalBattles: Int = 0
    
    
    for actualData in listActualData {
        if let expectedData = expectedDataDict[actualData.tank_id] {
            // Calculate WN8 for this tank
            let tankWN8 = calculateTankWn8(expectedData: expectedData, actualData: actualData)
            let weightedWN8 = tankWN8 * actualData.battles
            
            // Accumulate WN8 and battles
            sumTotalWN8 += weightedWN8
            totalBattles += actualData.battles
            
            
        } else {
            print("Warning: No expected data found for tank ID \(actualData.tank_id)")
        }
    }
    
    // Ensure totalBattles is greater than 0 to avoid division by zero
    guard totalBattles > 0 else {
        print("Error: Total battles is zero")
        return 0
    }
    
    // Calculate average WN8
    let averageWN8 = Double(sumTotalWN8) / Double(totalBattles)
    return Int(round(averageWN8))
}



func calculateEveryTankWn8(listExpectedData: [WN8ExpectedData], listActualData: [TankActualDataAvg]) -> [Int: Int] {
    var wn8Dict: [Int: Int] = [:]
    guard listExpectedData.count == listActualData.count else {
        print("Error: Mismatched list sizes")
        return [:] // Return an empty dictionary in case of mismatch
    }
    let expectedDataDict = Dictionary(uniqueKeysWithValues: listExpectedData.map { ($0.IDNum, $0) })
    
    for actualData in listActualData {
        if let expectedData = expectedDataDict[actualData.tank_id] {
            // Calculate WN8 for this tank
            let tankWN8 = calculateTankWn8(expectedData: expectedData, actualData: actualData)
            wn8Dict[actualData.tank_id] = tankWN8
        } else {
            print("Warning: No expected data found for tank ID \(actualData.tank_id)")
        }
    }

    return wn8Dict
}




func getPlayersEveryTankWn8(playerID: Int, completion: @escaping (Result<[Int: Int], Error>) -> Void) {
    var tankIDs: [Int] = []
    var listTankData: [TankData] = []
    var listExpectedWn8: [WN8ExpectedData] = []
    
    // Fetch tank IDs
    getPlayersTanksIds(accountID: playerID) { result in
        switch result {
        case .success(let ids):
            tankIDs = ids
            
            
            // Fetch player stats
            getPlayersStats(accountID: playerID) { statsResult in
                switch statsResult {
                case .success(let stats):
                    listTankData = stats
                    
                    // Fetch WN8 expected values
                    getExpectedValuesFiltered(tankIDs: tankIDs) { wn8Result in
                        switch wn8Result {
                        case .success(let wn8Data):
                            listExpectedWn8 = wn8Data
                            
                            // Calculate average values
                            let averageValuesAll = getAverageValuesAll(listTankData: listTankData)
                            
                            // Calculate WN8 for all tanks
                            let wn8Dict = calculateEveryTankWn8(listExpectedData: listExpectedWn8, listActualData: averageValuesAll)
                            
                            // Return the result
                            completion(.success(wn8Dict))
                        case .failure(let error):
                            print("Error fetching WN8 expected values: \(error)")
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print("Error fetching player stats: \(error)")
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            print("Error fetching player tank IDs: \(error)")
            completion(.failure(error))
        }
    }
}

func getPlayersWn8(playerID: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    // Fetch tank IDs
    getPlayersTanksIds(accountID: playerID) { result in
        switch result {
        case .success(let tankIDs):
            // Fetch player stats
            getPlayersStats(accountID: playerID) { statsResult in
                switch statsResult {
                case .success(let listTankData):
                    // Fetch WN8 expected values
                    getExpectedValuesFiltered(tankIDs: tankIDs) { wn8Result in
                        switch wn8Result {
                        case .success(let listExpectedWn8):
                            // Calculate average values
                            let averageValuesAll = getAverageValuesAll(listTankData: listTankData)
                            
                                    let wn8Value = calculateOverallWn8(
                                        listExpectedData: listExpectedWn8,
                                        listActualData: averageValuesAll
                                    )
                                    completion(.success(wn8Value))
                            
                        case .failure(let error):
                            print("Error fetching WN8 expected values: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print("Error fetching player stats: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            print("Error fetching player tank IDs: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}


    






func getExpectedValuesFiltered(tankIDs: [Int], completion: @escaping (Result<[WN8ExpectedData], Error>) -> Void) {
    fetchWN8ExpectedData(tanksIDs: tankIDs) { result in
        switch result {
        case .success(let filteredWN8Data):
            completion(.success(filteredWN8Data))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}




