//
//  ClanView.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import SwiftUI

struct ClanView: View {
    @State private var events: [Event] = []
    @State private var showAddEventForm = false
    @Binding var selectedTab: Int
    @Binding var profileInfo: Player?
    @Binding var clanBadgesCount: Int
  
    @EnvironmentObject var appData: AppData
    
    var body: some View {
            switch appData.currentSubviewClan {
            case .notLogged:
                ClanViewNotLogged(selectedTab: $selectedTab).environmentObject(appData)
            case .notInClan:
                ClanViewNotInClan()
            case .success:
                
                VStack{
                    if let clanInfo = profileInfo?.clan {
                        
                        
                        VStack{
                            ClanViewSuccess(clanBasicInfo: clanInfo,clanBadgesCount: $clanBadgesCount)
                        }
                       
                        
                        
                    } else {
                        VStack(){
                            Spacer()
                            ProgressView("Loading Clan Data...")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.darkGray))
                        .edgesIgnoringSafeArea(.all)
                        
                    }
                }.background(Color(UIColor.darkGray))
                    .onAppear {
                        if  profileInfo == nil {
                                    
                            let playerId = AppData.loggedPlayerID
                                    Task {
                                        if let fetchedPlayer = await getPlayer(playerId: playerId,authToken: AppData.AuthToken) {
                                            profileInfo = fetchedPlayer
                                                        
                                        }
                                        
                                    }
                                }
                            }
                
            }
        }
    
}






//#Preview {
//    let appdata: AppData = AppData()
//    ClanView().environmentObject(appdata)
//}
