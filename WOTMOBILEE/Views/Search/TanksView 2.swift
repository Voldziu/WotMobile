////
////  TanksView 2.swift
////  WOTMOBILEE
////
////  Created by Mikołaj Machalski on 06/01/2025.
////
//
//
//import SwiftUI
//
//struct TanksView: View {
//    @EnvironmentObject var appData: AppData
//    @State private var searchText: String = ""
//    @Binding var selectedTiers: Set<Int>
//    @Binding var selectedNations: Set<String>
//    @Binding var sortOrder: String
//    @Binding var ascending: Bool
//    @Binding var tanks: [Tank]
//    
//    // List of nations and tiers
//    let nations: [String] = ["poland","usa","uk","france","germany","italy","czech","japan","china","ussr","sweden"]
//    let tiers: [Int] = Array(1...10)
//    
//    
//    // Filtered tanks based on user input
//    var filteredTanks: [Tank] {
//        var filtered = tanks.filter { tank in
//            (searchText.isEmpty || tank.basicStats.short_name.lowercased().contains(searchText.lowercased())) &&
//            (selectedTiers.isEmpty || selectedTiers.contains(tank.basicStats.tier)) &&
//            (selectedNations.isEmpty || selectedNations.contains(tank.basicStats.nation))
//        }
//        
//        // Sort the filtered list
//        switch sortOrder {
//        case "nation":
//            filtered.sort { ascending ? $0.basicStats.nation < $1.basicStats.nation : $0.basicStats.nation > $1.basicStats.nation }
//        case "type":
//            filtered.sort { ascending ? $0.basicStats.type < $1.basicStats.type : $0.basicStats.type > $1.basicStats.type }
//        case "tier":
//            filtered.sort { ascending ? $0.basicStats.tier < $1.basicStats.tier : $0.basicStats.tier > $1.basicStats.tier }
//        case "name":
//            filtered.sort { ascending ? $0.basicStats.short_name < $1.basicStats.short_name : $0.basicStats.short_name > $1.basicStats.short_name }
//        case "wn8":
//            filtered.sort { ascending ? $0.stats.stats.wn8 < $1.stats.stats.wn8 : $0.stats.stats.wn8 > $1.stats.stats.wn8 }
//        case "winRate":
//            filtered.sort { ascending ? $0.stats.stats.wr < $1.stats.stats.wr : $0.stats.stats.wr > $1.stats.stats.wr }
//        case "battles":
//            filtered.sort { ascending ? $0.stats.stats.battles < $1.stats.stats.battles : $0.stats.stats.battles > $1.stats.stats.battles }
//        default:
//            break
//        }
//        
//        return filtered
//    }
//    var averageTier: Double {
//        let tiers = filteredTanks.compactMap { Double($0.basicStats.tier) }
//        return tiers.isEmpty ? 0.0 : tiers.reduce(0, +) / Double(tiers.count)
//    }
//    
//    var averageBattles: Double {
//        let battles = filteredTanks.map { Double($0.stats.stats.battles) }
//        return battles.isEmpty ? 0.0 : battles.reduce(0, +) / Double(battles.count)
//    }
//    
//    var averageWN8: Int {
//        let weightedSum = filteredTanks.reduce(0) { $0 + ($1.stats.stats.wn8 * $1.stats.stats.battles) }
//        let totalBattles = filteredTanks.reduce(0) { $0 + $1.stats.stats.battles }
//        let avgWn8 = totalBattles == 0 ? 0 : Int(weightedSum / totalBattles)
//        return avgWn8
//    }
//
//    var averageWinRate: Double {
//        let weightedSum = filteredTanks.reduce(0.0) { $0 + ($1.stats.stats.wr * Double($1.stats.stats.battles)) }
//        let totalBattles = filteredTanks.reduce(0.0) { $0 + Double($1.stats.stats.battles) }
//        return totalBattles == 0.0 ? 0.0 : weightedSum / totalBattles
//    }
//    
//    var body: some View {
//        VStack {
//            // Show a loading indicator if tanks are empty
//            if tanks.isEmpty {
//                ProgressView("Loading Tanks...")
//                    
//            } else {
//                // Main view when tanks are loaded
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 15) {
//                        TextField("Search tank...", text: $searchText)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.horizontal)
//                        
//                        // Tier filters
//                        ZStack {
//                            // Background for the entire ForEach block
//                            RoundedRectangle(cornerRadius: 5)
//                                .fill(Color.gray.opacity(0.1))
//                                .padding(.horizontal, 10)
//                                .frame(height:40)
//
//                            // The ForEach block
//                            HStack(spacing: 10) {
//                                ForEach(tiers, id: \.self) { tier in
//                                    Button(action: {
//                                        if selectedTiers.contains(tier) {
//                                            selectedTiers.remove(tier)
//                                        } else {
//                                            selectedTiers.insert(tier)
//                                        }
//                                    }) {
//                                        ZStack {
//                                            // Background Rectangle for each button
//                                            RoundedRectangle(cornerRadius: 5)
//                                                .fill(selectedTiers.contains(tier) ? Color.red.opacity(0.4) : Color.gray.opacity(0.2))
//
//                                            // Text inside the button
//                                            Text(arabicToRoman(tier))
//                                                .font(.caption)
//                                                .foregroundColor(.white)
//                                        }
//                                        .frame(width: 40, height: 30) // Ensure all buttons are the same size
//                                    }
//                                }
//                            }
//                            .padding()
//                        }
//                        
//                        // Nation filters
//                        ZStack {
//                            // Background for the entire block
//                            RoundedRectangle(cornerRadius: 5)
//                                .fill(Color.gray.opacity(0.1)) // Background color for the entire block
//                                .padding(.horizontal, 10)
//                                .frame(height:40)
//
//                            // ForEach block inside the ZStack
//                            HStack(spacing: 10) {
//                                ForEach(nations, id: \.self) { nation in
//                                    Button(action: {
//                                        if selectedNations.contains(nation) {
//                                            selectedNations.remove(nation)
//                                        } else {
//                                            selectedNations.insert(nation)
//                                        }
//                                    }) {
//                                        ZStack {
//                                            // Background for each button
//                                            RoundedRectangle(cornerRadius: 5)
//                                                .fill(selectedNations.contains(nation) ? Color.red.opacity(0.4) : Color.gray.opacity(0.2))
//
//                                            // The image inside the button
//                                            Image(nation)
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 38, height: 28) 
//                                                
//                                        }
//                                        .frame(width: 40, height: 30) // Size for the button
//                                    }
//                                }
//                            }
//                            .padding() // Padding for the HStack inside the ZStack
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                }
//                .padding(.top)
//                
//                VStack {
//                    ScrollView([.vertical, .horizontal], showsIndicators: true) {
//                        LazyVStack(alignment: .leading, spacing: 0) {
//                            // Column headers
//                            HStack(spacing: 0) {
//                                HeaderButton(title: "Nation", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "nation")
//                                    .frame(width: 100, alignment: .center)
//                                HeaderButton(title: "Type", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "type")
//                                    .frame(width: 65, alignment: .center)
//                                HeaderButton(title: "Tier", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "tier")
//                                    .frame(width: 60, alignment: .center)
//                                HeaderButton(title: "Name", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "name")
//                                    .frame(width: 185, alignment: .leading)
//                                HeaderButton(title: "Battles", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "battles")
//                                    .frame(width: 100, alignment: .center)
//                                HeaderButton(title: "WN8", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "wn8")
//                                    .frame(width: 70, alignment: .center)
//                                HeaderButton(title: "WR", sortOrder: $sortOrder, ascending: $ascending, currentOrder: "winRate")
//                                    .frame(width: 80, alignment: .center)
//                            }
//                            .background(Color(UIColor.systemGray5))
//                            VStack(spacing: 0) {
//                                // Average of Selection Row
//                                HStack(spacing: 0) {
//                                    Text(" ")
//                                        .frame(width: 165, alignment: .center)
//
//                                    Text(String(format: "%.2f", averageTier))
//                                        .frame(width: 60, alignment: .center)
//                                        .foregroundColor(.white)
//                                        .font(.headline) // Bigger font for visibility
//
//                                    Text("Average of selection")
//                                        .frame(width: 185, alignment: .leading)
//                                        .foregroundColor(.white)
//                                        .font(.headline) // Bigger font for the title
//                                         // Bold for emphasis
//
//                                    Text(String(format: "%.0f", averageBattles))
//                                        .frame(width: 100, alignment: .center)
//                                        .foregroundColor(.white)
//                                        .font(.headline)
//
//                                    Text(String(averageWN8))
//                                        .frame(width: 70, height: 40, alignment: .center)
//                                        .foregroundColor(.white)
//                                        .background(Color(getColorFromWn8(wn8Value: averageWN8)).opacity(0.5))
//                                        .font(.headline)
//
//                                    Text(String(format: "%.2f %%", averageWinRate))
//                                        .frame(width: 80, height: 40, alignment: .center)
//                                        .foregroundColor(.white)
//                                        .background(Color(getColorFromWinrate(wrValue: averageWinRate)).opacity(0.5))
//                                        .font(.headline)
//                                }
//                                .padding(.vertical, 12) // Slightly increased padding for better spacing
//
//                                // List of filtered tanks
//                                LazyVStack{
//                                    ForEach(filteredTanks)  { tank in
//                                        NavigationLink(destination: TankDetailView(tank: tank)) {
//                                            HStack(spacing: 0) {
//                                                Image("\(tank.basicStats.nation)")
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 100, height: 40, alignment: .center)
//
//                                                Image("\(tank.basicStats.type)")
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 65, height: 20, alignment: .center)
//
//                                                Text(arabicToRoman(tank.basicStats.tier))
//                                                    .frame(width: 60, alignment: .center)
//                                                    .foregroundColor(.white)
//                                                    .font(.body)
//                                                    .fontWeight(.medium)
//
//                                                HStack {
//                                                    if let contourIcon = UIImage(named: "\(tank.basicStats.tank_id)_contour") {
//                                                        Image(uiImage: contourIcon)
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(width: 65, alignment: .center)
//                                                    } else {
//                                                        Image(systemName: "photo")
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .foregroundColor(.gray)
//                                                            .frame(width: 65, alignment: .center)
//                                                    }
//
//                                                    Text(tank.basicStats.short_name)
//                                                        .foregroundColor(.white)
//                                                        .font(.body)
//                                                        .fontWeight(.medium)
//                                                        
//                                                }
//                                                .frame(width: 185, alignment: .leading)
//
//                                                Text("\(tank.stats.stats.battles)")
//                                                    .frame(width: 100, alignment: .center)
//                                                    .foregroundColor(.white)
//                                                    .font(.body)
//                                                    .fontWeight(.medium)
//
//                                                Text("\(tank.stats.stats.wn8)")
//                                                    .frame(width: 70, height: 40, alignment: .center)
//                                                    .foregroundColor(.white)
//                                                    .background(Color(getColorFromWn8(wn8Value: tank.stats.stats.wn8)).opacity(0.5))
//                                                    .font(.body)
//                                                    .fontWeight(.medium)
//
//                                                Text(String(format: "%.2f %%", tank.stats.stats.wr))
//                                                    .frame(width: 80, height: 40, alignment: .center)
//                                                    .foregroundColor(.white)
//                                                    .background(Color(getColorFromWinrate(wrValue: tank.stats.stats.wr)).opacity(0.5))
//                                                    .font(.body)
//                                                    .fontWeight(.medium)
//                                            }
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                    }
//                                }
//                                
//                            }.frame(minHeight: UIScreen.main.bounds.height,alignment:.top)
//                        }
//                    }
//                }
//            }
//        }
//    }}
//
//
//struct HeaderButton: View {
//    let title: String
//    @Binding var sortOrder: String
//    @Binding var ascending: Bool
//    let currentOrder: String
//
//    var body: some View {
//        Button(action: {
//            if sortOrder == currentOrder {
//                ascending.toggle()
//            } else {
//                sortOrder = currentOrder
//                ascending = true
//            }
//        }) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.black)
//                if sortOrder == currentOrder {
//                    Image(systemName: ascending ? "arrow.up" : "arrow.down")
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
////#Preview {
////    let appData = AppData()
////    TanksView().environmentObject(appData)
////}
