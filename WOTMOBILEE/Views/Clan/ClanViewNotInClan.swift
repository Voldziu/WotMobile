//
//  ClanViewNotInClan.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 10/12/2024.
//

import SwiftUI

struct ClanViewNotInClan: View {
    var body: some View {
            VStack {
                Spacer()
                
                Text("You are not a member of any clan")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                 
                
                Spacer()
                
                Button(action: {
                    // Akcja po kliknięciu
                    
                    if let url = URL(string: "https://na.wargaming.net/clans/wot/find_clan_anonymous/") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }) {
                    Text("SEARCH CLANS")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .background(Color(UIColor.darkGray)) // Tło aplikacji
            .edgesIgnoringSafeArea(.all) // Rozciągnięcie tła na cały ekran
        }
}

#Preview {
    ClanViewNotInClan()
}
