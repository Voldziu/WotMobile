//
//  ProfileViewSuccess.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 27/12/2024.
//

//
//  ClanViewNotLogged.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 10/12/2024.
//

import SwiftUI

struct ProfileViewSuccess: View {
    @Binding var profileTanks: [Tank]
    @Binding var profilePlayerData: Player?
    //@Binding var profilePrivateData
    
    
    @EnvironmentObject var appData: AppData
    var tabs = ["My Profile","Stats"]
    
    var body: some View {
        VStack {
            
            ProfileHeaderView(nickname: AppData.loggedPlayerNickname)
            // Segmented Control na górze widoku
            Picker("Tabs", selection: $appData.selectedProfileTab) {
                ForEach(tabs, id: \.self) { tab in
                    Text(tab).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Wyświetlanie odpowiedniego widoku w zależności od wyboru zakładki
            if appData.selectedProfileTab == "My Profile" {
                if let playerInfo = profilePlayerData?.playerInfo {
                    
                    
                    MyProfileView(profileData: playerInfo)
                } else {
                    ProgressView("Loading Player Data...")
                }
               
            } else if appData.selectedProfileTab == "Stats" {
                SearchedMain(tanks:$profileTanks,playerData: $profilePlayerData,playerID: AppData.$loggedPlayerID,playerName:AppData.$loggedPlayerNickname,selectedTab: $appData.selectedProfileStatsTab)
            }
            Spacer()
        } .background(Color(UIColor.darkGray))
            .onAppear {
                if  profilePlayerData == nil || profileTanks.isEmpty {
                            
                    let playerId = AppData.loggedPlayerID
                            Task {
                                if let fetchedPlayer = await getPlayer(playerId: playerId,authToken: AppData.AuthToken) {
                                    profilePlayerData = fetchedPlayer
                                                
                                }
                                if let fetchedTanks = await getTanks(playerId: playerId) {
                                    profileTanks = fetchedTanks
                                }
                            }
                        }
                    }
             
    }
}


struct MyProfileView: View {
    var profileData:PlayerInfo
    
    var body: some View {
        
        VStack {
            VStack(spacing:5){
                HStack {
                    Text("Created At: ")
                        .foregroundColor(Color.white)
                        .frame(alignment: .leading)
                    Spacer()
                    Text("\(formatUnixTime(profileData.created_at))")
                        .foregroundColor(Color.white)
                        .frame(alignment: .trailing)
                        .fontWeight(.bold)
                }

                HStack {
                    Text("Updated At: ")
                        .foregroundColor(Color.white)
                        .frame(alignment: .leading)
                    Spacer()
                    Text("\(formatUnixTime(profileData.updated_at))")
                        .foregroundColor(Color.white)
                        .frame(alignment: .trailing)
                        .fontWeight(.bold)
                }

                HStack {
                    Text("Hours spent playing: ")
                        .foregroundColor(Color.white)
                        .frame(alignment: .leading)
                    Spacer()
                    Text("\(profileData.privateData!.battle_life_time / 3600) h")
                        .foregroundColor(Color.white)
                        .frame(alignment: .trailing)
                        .fontWeight(.bold)
                }
                
                
                
            }.padding(.bottom,20)
                .padding(.horizontal,10)
            
            
            

            

            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // Gold Section
                    VStack {
                        Image("gold2") // Replace with your gold coin PNG file name
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(Color.clear) // Transparent background
                        Text("\(profileData.privateData!.gold)")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                    }

                    // Silver Section
                    VStack {
                        Image("credits") // Replace with your silver coin PNG file name
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(Color.clear) // Transparent background
                        Text("\(profileData.privateData!.credits)")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }

                    // Bonds Section
                    VStack {
                        Image("bonds") // Replace with your bonds PNG file name
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(Color.clear) // Transparent background
                        Text("\(profileData.privateData!.bonds)")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }

                    // Free XP Section
                    VStack {
                        Image("free_exp") // Replace with your free XP PNG file name
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(Color.clear) // Transparent background
                        Text("\(profileData.privateData!.free_xp)")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
            
        }
        .padding()
        
    }
}


struct ProfileHeaderView: View {
    var nickname: String
    @EnvironmentObject var appData: AppData
    var body: some View {
        ZStack {
            // Background stripe
            Color(UIColor.systemGray5)
                .frame(height: 60)

            // Centered nickname
            Text(nickname)
                .font(.headline)
                .foregroundColor(.green)

            // Right-aligned "Wyloguj" button
            HStack {
                Spacer()
                Button(action: {
                    // Handle logout action here
                    logout(appData: appData)
                }) {
                    Text("Log out")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}






