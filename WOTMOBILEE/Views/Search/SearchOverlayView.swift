//
//  SearchOverlayView.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import SwiftUI

struct SearchOverlayView: View {
    @Binding var showOverlay: Bool
    @Binding var selectedTab: Int
    @EnvironmentObject var appData: AppData
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Wyszukaj", text: $searchText)
                    .padding(.horizontal, 10)

                Spacer()
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .onSubmit {
                performSearch(searchText: searchText) { result in
                    switch result {
                    case .success(let account_id):
                        if !appData.pastSearches.contains(searchText) {
                            appData.addPastSearch(searchText)
                            print("Past searches: \(appData.pastSearches)")
                        }
                        print("Account ID: \(account_id)")
                    case .failure(let error):
                        print("Search failed: \(error.localizedDescription)")
                    }
                }
            }

            ScrollView(.vertical, showsIndicators: false) {
                if appData.favorites.isEmpty {
                    Text("NO FAVORITES")
                        .font(.caption)
                } else {
                    Text("FAVORITES")
                        .font(.caption)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(appData.favorites, id: \.self) { favorite in
                                Button(action: {
                                    performSearch(searchText: favorite) { result in
                                        switch result {
                                        case .success(let account_id):
                                            print("Favorite search succeeded with Account ID: \(account_id)")
                                        case .failure(let error):
                                            print("Favorite search failed: \(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(favorite)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button(action: {
                                            appData.removeFavorite(favorite)
                                        }) {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray2))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxHeight: 400)
                    }
                }

                Spacer()
                Text("PAST SEARCHES")
                    .font(.caption)
                    .padding(.horizontal, 20)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(appData.pastSearches, id: \.self) { search in
                            Button(action: {
                                performSearch(searchText: search) { result in
                                    switch result {
                                    case .success(let account_id):
                                        print("Past search succeeded with Account ID: \(account_id)")
                                    case .failure(let error):
                                        print("Past search failed: \(error.localizedDescription)")
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    Text(search)
                                        .foregroundColor(Color(.systemGray5))
                                    Spacer()
                                    Button(action: {
                                        appData.addFavorite(search)
                                        appData.pastSearches.removeAll { $0 == search }
                                    }) {
                                        Image(systemName: "star")
                                            .foregroundColor(.yellow)
                                    }
                                    Button(action: {
                                        appData.removePastSearch(search)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray2))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .scrollDisabled((appData.favorites.count + appData.pastSearches.count) < 5)
        }
        .frame(width: 300)
        .frame( maxHeight: min(CGFloat(280) + CGFloat(min(appData.favorites.count, 3) * 20) + CGFloat(min(appData.pastSearches.count, 3) * 20), 650))
        .background(Color.gray)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .transition(.opacity)
    }

    private func performSearch(searchText: String, completion: @escaping (Result<Int, Error>) -> Void) {
        print("Performing search for: \(searchText)")
        
        

        searchPlayer(nickname: searchText) { result in
            switch result {
            case .success(let account_id):
                DispatchQueue.main.async {
                    appData.searchedPlayerID = account_id
                    appData.searchedPlayerName = searchText
                    completion(.success(account_id))
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                
            }
            
            
        }
        withAnimation(.easeInOut(duration: 0.4)) {
            showOverlay = false
            if(selectedTab != 1){
                selectedTab = 1
            }
        }

        
    }
}
