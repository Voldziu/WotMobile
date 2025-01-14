//
//  SearchedMain.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 29/11/2024.
//



import SwiftUI

struct SearchedMain: View {
   
    @EnvironmentObject var appData: AppData
 

    @State private var selectedTiers: Set<Int> = []
    @State private var selectedNations: Set<String> = []
    @State private var sortOrder: String = "battles"
    @State private var ascending: Bool = false
    
    @Binding var tanks:[Tank]
    @Binding var playerData:Player?
    @Binding var playerID: Int
    @Binding var playerName: String
    @Binding var selectedTab: String
    
    var tabs = ["Main", "Tanks"]

    var body: some View {
        VStack {
            if(playerID==0){
                Text("Search a player!")
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.top,50)
                   
            } else{
                Picker("Tabs", selection: $selectedTab) {
                    ForEach(tabs, id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

            
                if selectedTab == "Main" {
                    MainStatsView(playerData:$playerData,tanks:$tanks,playerName:$playerName)
                } else if selectedTab == "Tanks" {
                    TanksView(selectedTiers:$selectedTiers,selectedNations:$selectedNations, sortOrder:$sortOrder, ascending:$ascending,tanks:$tanks) // Nowy widok dla zakładki Tanks
                }
            }
            
        }.background(Color(UIColor.darkGray))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                        if playerID != 0 && playerData == nil && tanks.isEmpty {
                            
                            let playerId = playerID
                            Task {
                                if let fetchedPlayer = await getPlayer(playerId: playerId) {
                                     playerData = fetchedPlayer
                                                
                                }
                                if let fetchedTanks = await getTanks(playerId: playerId) {
                                    tanks = fetchedTanks
                                }
                            }
                        }
                    }
        
            .onChange(of: playerID) {_, newValue in
            playerData = nil
            tanks = []
                if(newValue != 0){
                    print("dupa")
                    print(newValue)
                        let playerId = newValue
                        Task {
                            if let fetchedPlayer = await getPlayer(playerId: playerId) {
                                 playerData = fetchedPlayer
                                            
                            }
                            if let fetchedTanks = await getTanks(playerId: playerId) {
                                tanks = fetchedTanks
                            }
                        }
                }
            
                // TU TRZEBA POMYSLEC ZEBY SIE ODSWIEZALO JAK SIE ZMIENIA NICK Z POZIOMU CZOLGOW
        }
    }
}

       







//#Preview {
//    let appData = AppData()
//    SearchedMain().environmentObject(appData)
//}

