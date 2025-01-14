//
//  MainStatsView.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 03/01/2025.
//
import SwiftUI

struct MainStatsView: View {
    @EnvironmentObject var appData: AppData
    @Binding var playerData:Player?
    @Binding var tanks:[Tank]
    @Binding var playerName: String
    
    var body: some View {
        VStack(spacing: 16) {
            if playerData == nil {
                ProgressView("Loading Player Data...")
            } else if(playerData?.stats == nil){
                Text("No player found")
            }
            else {
                
                
                
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if playerData!.clan != nil {
                            // Show clan information if the player is in a clan
                            VStack(alignment:.leading, spacing: 2) {
                                Text("[\(playerData!.clan!.clan!.tag)]") // Clan tag
                                    .font(.title2)
                                    .foregroundColor(Color(hex: playerData!.clan!.clan!.color)) // Clan color
                                    
                                Text(playerData!.clan!.roleI18n)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // Show "No Clan" with the same size and alignment as the clan tag
                            VStack(spacing: 2) {
                                Text("No Clan")
                                    .font(.title2) // Same font size as the clan tag
                                    .foregroundColor(.gray) // Fallback color
                                    
                                 Text("")
                            }
                        }

                        // Player name
                        Text(playerName) // Player name
                            .font(.title2)
                            .foregroundColor(.white) // WN8 color
                    }

                    Spacer()

                    // Right side: Dates
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Gaming since: \(formatUnixTime(playerData!.playerInfo!.created_at))") // Player gaming start date
                            .foregroundColor(.gray)
                        Text("Last update: \(formatUnixTime(playerData!.playerInfo!.updated_at))") // Last update date
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top,20)
                
                // Kolumny ze statystykami
                ScrollView() {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatBox(title: "WN8", value: "\(playerData!.stats!.wn8)", color: Color(getColorFromWn8(wn8Value: playerData!.stats!.wn8)).opacity(0.5))
                        StatBox(title: "WR", value: String(format: "%.1f%%", playerData!.stats!.wr), color: Color(getColorFromWinrate(wrValue: playerData!.stats!.wr)).opacity(0.5))
                        StatBox(title: "DPG", value: "\(playerData!.stats!.dpg)")
                        StatBox(title: "Spots", value: String(format: "%.1f", playerData!.stats!.spots))
                        StatBox(title: "Survived", value: String(format: "%.1f%%", playerData!.stats!.surived))
                        StatBox(title: "Armor Eff.", value: String(format: "%.1f", playerData!.stats!.armorEff))
                        StatBox(title: "Battles", value: "\(playerData!.stats!.battles)")
                        StatBox(title: "DD/DR", value: String(format: "%.1f", playerData!.stats!.DDDR))
                        StatBox(title: "KD", value: String(format: "%.1f", playerData!.stats!.KD))
                        StatBox(title: "Hit %", value: String(format: "%.1f%%", playerData!.stats!.hitPercentage))
                        StatBox(title: "XP/Game", value: "\(playerData!.stats!.xppg)")

                    }
                    .padding()
                }.frame(height:400)
            }
            
        }
        
    }
}
