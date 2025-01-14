//
//  PremiumShopList.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import SwiftUI

struct ArticleList: View {
    let articles: [Article]

    var body: some View {
        TabView {
            ForEach(articles, id: \.id) { article in
                ArticleView(article: article)
                    .frame(width: 400, height: 400)
                    .clipped()
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 400)
    }
}


