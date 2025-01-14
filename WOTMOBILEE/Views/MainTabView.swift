





import SwiftUI

struct MainTabView: View {
    @State private var tanks: [Tank] = []
    @State private var playerData: Player? = nil
    @State private var profileTanks: [Tank] = []
    @State private var profilePlayerData: Player? = nil
    @State private var selectedTab: Int = 0
    @State private var clanBadgesCount:Int=0
    @StateObject private var appData = AppData()
    
    var body: some View {
        
            
       
        VStack(spacing: 0) {
            
            // Główna zawartość na podstawie wybranej zakładki
            switch selectedTab {
            case 0:
                HomeView(selectedTab: $selectedTab)
                    
                    .environmentObject(appData)
            case 1:
                NavigationStack{
                    SearchView(selectedTab: $selectedTab, tanks: $tanks, playerData: $playerData)
                        
                        .environmentObject(appData)
                }
                
            case 2:
                ClanView(selectedTab:$selectedTab,profileInfo: $profilePlayerData,clanBadgesCount: $clanBadgesCount)
                    
                    .environmentObject(appData)
            case 3:
                NavigationStack{
                    
                    
                    ProfileView(profileTanks: $profileTanks, profilePlayerData: $profilePlayerData)
                    
                        .environmentObject(appData)
                }
            default:
                HomeView(selectedTab: $selectedTab)
                    
                    .environmentObject(appData)
            }
        }
            
            // TabView z powiększonym obszarem klikalnym
            TabView(selection: $selectedTab) {
                            Color.clear
                                .tabItem {
                                    VStack {
                                        Image(systemName: "house")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .contentShape(Rectangle()) // Zwiększenie obszaru klikalnego
                                        Text("Home")
                                    }
                                    .padding()
                                }
                                .tag(0)
                            
                            // Zakładka "Search"
                            Color.clear
                                .tabItem {
                                    VStack {
                                        Image(systemName: "magnifyingglass")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .contentShape(Rectangle()) // Zwiększenie obszaru klikalnego
                                        Text("Search")
                                    }
                                    .padding()
                                }
                                .tag(1)

                            // Zakładka "Clan"
                            Color.clear
                                .tabItem {
                                    VStack {
                                        Image(systemName: "flag.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .contentShape(Rectangle()) // Zwiększenie obszaru klikalnego
                                        Text("Clan")
                                    }
                                    .padding()
                                }
                                .tag(2)
                                .badge(clanBadgesCount)

                            // Zakładka "Profile"
                            Color.clear
                                .tabItem {
                                    VStack {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .contentShape(Rectangle()) // Zwiększenie obszaru klikalnego
                                        Text("Profile")
                                    }
                                    .padding()
                                }
                                .tag(3)
                        }
            .frame(height: 30)
            .accentColor(.red)
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor.systemGray
            }
        }
    
}









            


#Preview {
    MainTabView()
}
