//
//  ClanViewNotLogged.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 10/12/2024.
//

import SwiftUI

struct ClanViewNotLogged: View {
    @EnvironmentObject var appData: AppData
    @Binding var selectedTab: Int
    var body: some View {
            VStack {
                Spacer()
                
                Text("To view clan information you need to log in")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: {
                    Login(appData:appData)
                    withAnimation(.easeInOut(duration: 0.4)) {
                        selectedTab = 3
                    }
                    
                }) {
                    Text("Log in")
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

//#Preview {
//    ClanViewNotLogged()
//}
