//
//  WotMobileApp.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 19/11/2024.
//

import SwiftUI

import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {

    
    
  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()
    
      let firestore = Firestore.firestore()
      let settings = FirestoreSettings()
      FirebaseConfiguration.shared.setLoggerLevel(.min)
      var cacheSettings = PersistentCacheSettings()
            settings.cacheSettings = cacheSettings
            firestore.settings = settings
      
    signInAnonymously()

    return true

  }
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Przejęty URL: \(url.absoluteString)")

    
        return true
    }
   

    

}


@main
struct WotMobile: App {



      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    

    

  var body: some Scene {

    WindowGroup {

      

        MainTabView()

      

    }

  }

}
