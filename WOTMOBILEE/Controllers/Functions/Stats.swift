//
//  Stats.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation



struct TankStats:Codable{
    
    let tank_id:Int
    var stats:StatsAll
    
}

struct StatsAll:Codable{
    var wn8:Int
    var wr:Double
    var dpg:Int
    var fragspg:Double
    var DDDR:Double //Damage Done / Damage Received
    var KD: Double
    var surived: Double
    var xppg: Int //XP per game
    var hitPercentage: Double
    var armorEff:Double
    var spots:Double
    var battles:Int
    
}
func getPlayersStatsDefinite(playerID: Int, completion: @escaping (Result<StatsAll, Error>) -> Void) {
    getPlayerInfo(playerId: playerID) { result in
        switch result {
        case .success(let playerInfo):
            print("Nickname: \(playerInfo.nickname)")
            print("Battles: \(playerInfo.statistics.all.battles)")
            print("Wins: \(playerInfo.statistics.all.wins)")
            
            let stats = playerInfo.statistics.all
            
            getPlayersWn8(playerID: playerID) { wn8Result in
                switch wn8Result {
                case .success(let wn8):
                    print("Player WN8: \(wn8)")
                    
                    // Calculate other profile stats
                    var profileStats = calculateStatsNoWn8(tankDataStats: stats)
                    profileStats.wn8 = wn8
                    
                    // Return profileStats
                    completion(.success(profileStats))
                    
                case .failure(let error):
                    print("Error calculating WN8: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
        case .failure(let error):
            print("Error fetching player info: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}

func getPlayersTanksStatsDefinite(playerID: Int, completion: @escaping (Result<[TankStats], Error>) -> Void) {
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
                            var listTankStats = calculateTanksStatsNoWn8(listTankData: listTankData)
                            addWn8ToTanksStats(wn8Dict: wn8Dict, tankStats: &listTankStats)
                            // Return the result
                            completion(.success(listTankStats))
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
func addWn8ToTanksStats(wn8Dict: [Int: Int], tankStats: inout [TankStats]) {
    for i in 0..<tankStats.count {
        if let wn8 = wn8Dict[tankStats[i].tank_id] {
            tankStats[i].stats.wn8 = wn8
        } else {
            print("Warning: No WN8 value found for tank ID \(tankStats[i].tank_id)")
        }
    }
}

func calculateTanksStatsNoWn8(listTankData:[TankData])->[TankStats]{
    var returnList:[TankStats] = []
    for tank in listTankData{
        let tankStats = TankStats(tank_id: tank.tank_id, stats: calculateStatsNoWn8(tankDataStats: tank.all))
        returnList.append(tankStats)
    }
    
    return returnList
    
    
}

func calculateStatsNoWn8(tankDataStats: DetailedStats) -> StatsAll {
    var all = tankDataStats
    
    // Placeholder for WN8 calculation, this requires expected values and specific logic
    var wn8 = 0

    // Win Rate (WR) as a percentage
    let wr = all.battles > 0 ? Double(all.wins) / Double(all.battles) * 100.0 : 0.0

    // Damage Per Game (DPG)
    let dpg = all.battles > 0 ? all.damage_dealt / all.battles : 0

    // Frags Per Game
    let fragspg = all.battles > 0 ? Double(all.frags) / Double(all.battles) : 0.0

    // Damage Done / Damage Received (DDDR)
    let DDDR = all.damage_received > 0 ? Double(all.damage_dealt) / Double(all.damage_received) : 0.0

    // Kill/Death Ratio (KD)
    let KD = (all.battles > 0 && all.battles - all.survived_battles > 0) ? Double(all.frags) / Double(all.battles - all.survived_battles) : 0.0

    // Survival Rate (percentage of battles survived)
    let survived = all.battles > 0 ? Double(all.survived_battles) / Double(all.battles) * 100.0 : 0.0

    // XP Per Game (XPPG)
    let xppg = all.battles > 0 ? all.xp / all.battles : 0

    // Hit Percentage
    let hitPercentage = all.shots > 0 ? Double(all.hits) / Double(all.shots) * 100.0 : 0.0

    // Armor Efficiency (damage blocked / damage received)
    let armorEff = all.damage_received > 0 ? all.avg_damage_blocked / Double(all.damage_received) : 0.0

    // Spots Per Game
    let spots = all.battles > 0 ? Double(all.spotted) / Double(all.battles) : 0.0

    return StatsAll(
        wn8: wn8,
        wr: wr,
        dpg: dpg,
        fragspg: fragspg,
        DDDR: DDDR,
        KD: KD,
        surived: survived,
        xppg: xppg,
        hitPercentage: hitPercentage,
        armorEff: armorEff,
        spots: spots,
        battles: all.battles
    )
}

