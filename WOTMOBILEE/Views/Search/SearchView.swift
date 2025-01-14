//
//  SearchView.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 03/01/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var showOverlay: Bool = false // Zmienna do zarządzania nakładką
    @Binding var selectedTab:Int
    @Binding var tanks:[Tank]
    @Binding var playerData:Player?
    @EnvironmentObject var appData: AppData
    
    
    var body: some View {
        ZStack {
            VStack {
                // Search bar
                Button(action: {
                    withAnimation {
                        showOverlay = true
                    }
                }) {
                    HStack {
                        Text("Search")
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .padding(.horizontal,20)
                .padding(.top,60)
                .disabled(showOverlay)
                
                
                VStack {
                    
                    SearchedMain(tanks:$tanks,playerData: $playerData,playerID: $appData.searchedPlayerID,playerName: $appData.searchedPlayerName,selectedTab: $appData.selectedSearchedTab)
                    Spacer()
                }
            }.background(Color(UIColor.darkGray)) // Ensures the entire view darkens
                .blur(radius: showOverlay ? 5 : 0)
                .zIndex(1)
            
            .onTapGesture {
                if showOverlay {
                    withAnimation {
                        showOverlay = false
                    }
                }
            }
            
            if showOverlay {
                SearchOverlayView(showOverlay: $showOverlay,selectedTab: $selectedTab).zIndex(2)
                
            }
                
            
        }.background(showOverlay ? Color.black.opacity(0.8) : Color.clear)
    }}



enum SubviewTypeSearched{
    case main
    case tanks
}


