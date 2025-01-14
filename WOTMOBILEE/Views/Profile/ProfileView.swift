//
//  ProfileView.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import SwiftUI

struct ProfileView: View {
    @Binding var profileTanks: [Tank]
    @Binding var profilePlayerData: Player?
    
    @EnvironmentObject var appData: AppData
    
    
    var body: some View {
        switch appData.currentSubviewProfile {
            case .notLogged:
            ProfileViewNotLogged().environmentObject(appData)
            case .success:
            ProfileViewSuccess(profileTanks: $profileTanks, profilePlayerData: $profilePlayerData).environmentObject(appData)
        }
        
    }
}

//#Preview {
//    let appdata: AppData = AppData()
//    ProfileView().environmentObject(appdata)
//}
