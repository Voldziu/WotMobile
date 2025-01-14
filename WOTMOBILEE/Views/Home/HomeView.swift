//
//  HomeView.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 03/01/2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab:Int
    @State private var showOverlay: Bool = false // Zmienna do zarządzania nakładką
    @EnvironmentObject var appData: AppData
    
    @State private var articles: [Article] = [] // Articles fetched from the web
    @State private var isLoading: Bool = true
    
    
    var body: some View {
        ZStack {
            
            VStack {
                // Search bar
                Button(action: {
                    withAnimation {
                        showOverlay = true
                    }
                }) {
                    HStack {
                        Text("Search")
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .padding(.horizontal,20)
                .padding(.top,60)
                .disabled(showOverlay)
                
                
                VStack {
                    if isLoading {
                        // Show a loading indicator while articles are being fetched
                        ProgressView("Loading Articles...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.top, 20)
                    } else {
                        if articles.isEmpty {
                            // Show message if no articles are available
                            Text("No articles available.")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        } else {
                            // Display the articles in the ArticleList
                            ArticleList(articles: articles)
                                .padding(.top, 20)
                        }
                    }
                    Spacer()
                }
            }
            .background(showOverlay ? Color.black.opacity(0.8) : Color(UIColor.darkGray)).blur(radius: showOverlay ? 5 : 0).zIndex(1)
            .onTapGesture {
                if showOverlay {
                    withAnimation {
                        showOverlay = false
                    }
                }
            }
            .onAppear(){
                fetchArticles()
            }
            
            if showOverlay {
                SearchOverlayView(showOverlay: $showOverlay,selectedTab: $selectedTab).zIndex(2)
                
            }
            
            
        }
    }
    
    func fetchArticles() {
            let url = "https://worldoftanks.eu/pl/"
            fetchHTML(from: url) { html in
                if let html = html {
                    scrapeArticles(from: html) { fetchedArticles in
                        DispatchQueue.main.async {
                            articles = fetchedArticles
                            isLoading = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                    print("Failed to retrieve HTML.")
                }
            }
        }
    
}


