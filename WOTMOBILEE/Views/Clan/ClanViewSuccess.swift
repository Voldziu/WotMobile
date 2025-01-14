import SwiftUI
import Kingfisher
struct ClanViewSuccess: View {
    @EnvironmentObject var appData: AppData
    
    @State private var events: [Event] = []
    @State private var showAddEventForm = false
    var clanBasicInfo: ClanMemberInfo
    
    @State private var ClanMemberNicknamesList: [String]=[]
    @State private var isLoading: Bool = true
    
    @Binding var clanBadgesCount: Int
    
    private let firebaseService = FirebaseService()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }()

    var body: some View {
        VStack {
            // Clan Header
            ClanHeaderView(
                clanName: clanBasicInfo.clan!.name, clanTag: clanBasicInfo.clan!.tag, clanColorHex: clanBasicInfo.clan!.color,
                clanImageURL: clanBasicInfo.clan!.emblems.x32.portal!
            )
            
            // Active Players
            
            HStack{
                Spacer()
                Text("Online:")
                    .foregroundColor(.green)
                    .padding(.horizontal,15)
                    .padding(.vertical,5)
                    
                Spacer()
            }
            
            if(isLoading){
                ProgressView("Loading clan members....")
                    
            } else{
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ClanMemberNicknamesList, id: \.self) { player in
                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 10, height: 10)
                            
                            Text(player)
                                .padding(8)
                                .cornerRadius(8)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top,10)
                }.refreshable {
                    loadClanMemberNicknames()
                } // Refresh while scrolling
            }
            
            HStack {
                    Text("Events")
                    .font(.headline)
                    .foregroundColor(.white)
                    
                    
                    Button(action: {
                        showAddEventForm.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle") // Icon for clarity
                            
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
            }.padding(.horizontal,20)
                .padding(.vertical,20)

            // Event List with Pull-to-Refresh
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($events) { event in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.wrappedValue.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.red)
                                .cornerRadius(4)
                            
                            Text("Start: \(dateFormatter.string(from: event.wrappedValue.datetimestart))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Text("End: \(dateFormatter.string(from: event.wrappedValue.datetimeend))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Text("Participants: \(event.wrappedValue.participants.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    deleteEvent(event.wrappedValue.id)
                                }) {
                                    Text("Delete")
                                        .padding()
                                        .background(
                                            ((appData.positionHierarchy[AppData.LoggedClanRank]) ?? 11 > event.wrappedValue.rank)
                                                ? Color.red.opacity(0.5)
                                                : Color.red.opacity(0.8)
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .disabled((appData.positionHierarchy[AppData.LoggedClanRank]) ?? 11 > event.wrappedValue.rank)
                                
                                Button(action: {
                                    if event.wrappedValue.participantsID.contains(AppData.loggedPlayerID) {
                                        leaveEvent(eventID: event.id)
                                    } else {
                                        joinEvent(eventID: event.id)
                                    }
                                }) {
                                    Text(event.wrappedValue.participantsID.contains(AppData.loggedPlayerID) ? "Dismiss" : "Enroll")
                                        .padding()
                                        .background(event.wrappedValue.participantsID.contains(AppData.loggedPlayerID) ? Color.blue.opacity(0.4) : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                Text("\(event.wrappedValue.participants.count)/\(event.wrappedValue.maxParticipants)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .refreshable {
                    loadEvents()
                    loadClanMemberNicknames()
                } // Refresh while scrolling
            }
            .onAppear {
                loadEvents()
                loadClanMemberNicknames()
            }
        }
        .sheet(isPresented: $showAddEventForm) {
            AddEventForm(clanId: AppData.LoggedClanID, madeById: AppData.loggedPlayerID, rank: (appData.positionHierarchy[AppData.LoggedClanRank]) ?? 11) { newEvent in
                addEvent(newEvent)
                joinEvent(eventID: newEvent.id)
            }
        }
        .background(Color(UIColor.darkGray).edgesIgnoringSafeArea(.all))
        
        
        
        
    }

    func loadClanMemberNicknames() {
        isLoading=true
        let clanId = clanBasicInfo.clan!.clanID
        let authToken = AppData.$AuthToken.wrappedValue
        ClanMemberNicknamesList = []
        
            Task {
                    do {
                        let nicknames =  await getOnlineClanMemberNicknames(clanId: clanId, authToken: authToken)
                        // Ensure UI updates happen on the main thread
                        self.ClanMemberNicknamesList = nicknames
                        print(self.ClanMemberNicknamesList)
                        self.isLoading = false
                        
                    }
                       
                    }
            
        
        }
    
    

    // MARK: - Load Events
    func loadEvents() {
        firebaseService.fetchEvents(clanID:AppData.LoggedClanID) { fetchedEvents, error in
            if let error = error {
                print("Błąd pobierania wydarzeń: \(error)")
            } else if let fetchedEvents = fetchedEvents {
                events = fetchedEvents
                clanBadgesCount = events.count
            }
        }
    }

    // MARK: - Add Event
    func addEvent(_ event: Event) {
        firebaseService.addEvent(event,clanID: AppData.LoggedClanID) { error in
            if let error = error {
                print("Błąd dodawania wydarzenia: \(error)")
            } else {
                loadEvents()
            }
        }
    
    }

    // MARK: - Delete Event
    func deleteEvent(_ eventID: String) {
        firebaseService.deleteEvent(clanID:AppData.LoggedClanID, eventID: eventID) { error in
            if let error = error {
                print("Błąd usuwania wydarzenia: \(error)")
            } else {
                loadEvents()
            }
        }
    }
    
    // MARK: - Join Event
    func joinEvent(eventID: String) {
        firebaseService.joinEvent( clanID: AppData.LoggedClanID,eventID: eventID, playerNickname: AppData.loggedPlayerNickname, playerID: AppData.loggedPlayerID) { error in
            if let error = error {
                print("Błąd zapisywania się na wydarzenie: \(error)")
            } else {
                print("Użytkownik \(AppData.loggedPlayerID) zapisany na wydarzenie \(eventID).")
                if let index = events.firstIndex(where: { $0.id == eventID }) {
                    events[index].participantsID.append(AppData.loggedPlayerID)
                }
                loadEvents()
            }
        }
    }
    func leaveEvent(eventID: String) {
        firebaseService.leaveEvent( clanID: AppData.LoggedClanID, eventID: eventID, playerNickname: AppData.loggedPlayerNickname, playerID: AppData.loggedPlayerID) { error in
            if let error = error {
                print("Błąd wypisywania się z wydarzenia: \(error)")
            } else {
                print("Użytkownik \(AppData.loggedPlayerID) wypisany z wydarzenia \(eventID).")
                if let index = events.firstIndex(where: { $0.id == eventID }) {
                    events[index].participantsID.removeAll { $0 == AppData.loggedPlayerID } // Remove user ID
                }
                loadEvents()
            }
        }
    }
    
    
    


}





struct ClanHeaderView: View {
    var clanName:String
    var clanTag:String
    var clanColorHex:String
    var clanImageURL: String
    
    var body: some View {
        ZStack {
            // Background stripe
            Color(UIColor.systemGray5)
                .frame(height: 60) // Stripe height
                 // Rounded corners
            
            // Clan content
           
                HStack {
                    
                   
                    // Clan Image
                    KFImage(URL(string:clanImageURL))
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    // Clan Tag and Name
                    VStack(alignment: .center, spacing: 4) {
                        
                        HStack{
                         
                            Text("[\(clanTag)]") // Clan tag
                                .font(.headline)
                                .foregroundColor(Color(hex: clanColorHex))
                                
                            
                        }
                        
                        HStack{
                            
                            Text(clanName) // Clan name
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                
                        }
                        
                    
                        
                    }
                    
                    
                }
                .padding(.horizontal, 16)
            
        }
        
    }
}


//#Preview {
//    let appData = AppData()
//    ClanViewSuccess().environmentObject(appData)
//}

