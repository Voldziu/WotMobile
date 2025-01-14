import SwiftUI

struct TankDetailView: View {
    let tank: Tank

    // Grid layout for stats
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Function to map tank types
    func getTankType(from type: String) -> String {
        switch type {
        case "AT-SPG":
            return "Tank Destroyer"
        case "SPG":
            return "SPG"
        case "heavyTank":
            return "Heavy Tank"
        case "lightTank":
            return "Light Tank"
        case "mediumTank":
            return "Medium Tank"
        default:
            return "Unknown Type"
        }
    }
    func getNationAdjective(from nation: String) -> String {
        switch nation.lowercased() {
        case "poland":
            return "Polish"
        case "usa":
            return "American"
        case "uk":
            return "British"
        case "france":
            return "French"
        case "germany":
            return "German"
        case "italy":
            return "Italian"
        case "czech":
            return "Czech"
        case "japan":
            return "Japanese"
        case "china":
            return "Chinese"
        case "ussr":
            return "Soviet"
        case "sweden":
            return "Swedish"
        default:
            return "Unknown Nation"
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Tier at the top
            HStack{
                VStack {
                    Text("TIER")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text(arabicToRoman(tank.basicStats.tier))
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .padding(.bottom,5)
                    Text(tank.basicStats.short_name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)

                    // Nation + Type
                    HStack{
                        Image("\(tank.basicStats.nation)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 40, alignment: .center)
                        Text(getNationAdjective(from: tank.basicStats.nation))
                            .font(.headline)
                            
                            .foregroundColor(.yellow)
                    }
                    
                    Text(getTankType(from: tank.basicStats.type))
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
                if let bigIcon = UIImage(named: "\(tank.basicStats.tank_id)_big_icon") {
                    Image(uiImage: bigIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(maxHeight: 150)
                }
                
            }
            

           
            

            // Scrollable stats grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatBox(title: "WN8", value: "\(tank.stats.stats.wn8)", color: Color(getColorFromWn8(wn8Value: tank.stats.stats.wn8)).opacity(0.5))
                    StatBox(title: "WR", value: String(format: "%.1f%%", tank.stats.stats.wr), color: Color(getColorFromWinrate(wrValue: tank.stats.stats.wr)).opacity(0.5))
                    StatBox(title: "DPG", value: "\(tank.stats.stats.dpg)")
                    StatBox(title: "Spots", value: String(format: "%.1f", tank.stats.stats.spots))
                    StatBox(title: "Survived", value: String(format: "%.1f%%", tank.stats.stats.surived))
                    StatBox(title: "Armor Eff.", value: String(format: "%.1f", tank.stats.stats.armorEff))
                    StatBox(title: "Battles", value: "\(tank.stats.stats.battles)")
                    StatBox(title: "DD/DR", value: String(format: "%.1f", tank.stats.stats.DDDR))
                    StatBox(title: "KD", value: String(format: "%.1f", tank.stats.stats.KD))
                    StatBox(title: "Hit %", value: String(format: "%.1f%%", tank.stats.stats.hitPercentage))
                    StatBox(title: "XP/Game", value: "\(tank.stats.stats.xppg)")
                }
            }
            .padding()
        }
        .background(Color(UIColor.darkGray))
        .navigationTitle(tank.basicStats.short_name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
