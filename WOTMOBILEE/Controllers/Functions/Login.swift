//
//  Login.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 30/12/2024.
//

import Foundation


func Login(appData:AppData) {
    loginWargaming { result in
        switch result {
        case .success(let wargamingAuthResponse):
            print("Zalogowano pomyślnie:")
            print("Status: \(wargamingAuthResponse.status)")
            print("Access Token: \(wargamingAuthResponse.access_token)")
            print("Nickname: \(wargamingAuthResponse.nickname)")
            print("Account ID: \(wargamingAuthResponse.account_id)")
            print("Expires At: \(wargamingAuthResponse.expires_at)")
            processLogin(appData: appData,wargaminAuthResponse: wargamingAuthResponse)
            getClanMemberInfo(playerID: Int(wargamingAuthResponse.account_id)!) { result in
                switch result {
                case .success(let clanMemberInfo):
                    if (clanMemberInfo?.clan != nil){
                        print("Player is in a clan!")
                        if let clan = clanMemberInfo?.clan {
                                        print("Clan ID: \(clan.clanID)")
                                        print("Clan Name: \(clan.name)")
                                        print("Clan Tag: \(clan.tag)")
                            
                            processClanInfo(appData: appData,clanID: clan.clanID, clanName: clan.name, clanTag: clan.tag, clanColor: clan.color,clanMemberRank: clanMemberInfo!.roleI18n)
                                    }
                    } else {
                        print("Player not in a clan")
                    }
                    
                        
                    
                   
                    
                    
                    
                    
        
                    
                case .failure(let error):
                    print("Error fetching clan info: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            print("Błąd logowania: \(error.localizedDescription)")
        }
    }
    
    
}


func logout(appData:AppData){
    processLogout(appData: appData)
    clearCookies(for: "api.worldoftanks.eu")
}


func isLogged() -> Bool {
    return (AppData.$loggedPlayerID.wrappedValue != 0)
}


func processLogin(appData:AppData,wargaminAuthResponse: WargamingAuthResponse){
    let accessToken = wargaminAuthResponse.access_token
    let nickname = wargaminAuthResponse.nickname
    let accountId = wargaminAuthResponse.account_id
    let expiresAt = wargaminAuthResponse.expires_at
    
    AppData.$AuthToken.wrappedValue=accessToken
    AppData.$loggedPlayerID.wrappedValue = Int(accountId)!
    AppData.$AuthTokenExpiresAt.wrappedValue = Int(expiresAt)!
    AppData.$loggedPlayerNickname.wrappedValue = nickname
    DispatchQueue.main.async{
        appData.currentSubviewProfile = .success
        appData.currentSubviewClan = .notInClan
    }
    
    
}

func processClanInfo(appData:AppData,clanID:Int,clanName:String,clanTag:String,clanColor: String,clanMemberRank: String){
    AppData.$LoggedClanID.wrappedValue = clanID
    AppData.$LoggedClanName.wrappedValue = clanName
    AppData.$LoggedClanTag.wrappedValue = clanTag
    AppData.$LoggedClanColor.wrappedValue=clanColor
    AppData.$LoggedClanRank.wrappedValue=clanMemberRank
    DispatchQueue.main.async{
        appData.currentSubviewClan = .success
        
    }
    
}


func processLogout(appData:AppData){
    AppData.$LoggedClanID.wrappedValue = 0
    AppData.$loggedPlayerID.wrappedValue = 0
    AppData.$loggedPlayerNickname.wrappedValue = ""
    AppData.$AuthToken.wrappedValue=""
    DispatchQueue.main.async{
        appData.currentSubviewProfile = .notLogged
        appData.currentSubviewClan = .notLogged
    }
}


