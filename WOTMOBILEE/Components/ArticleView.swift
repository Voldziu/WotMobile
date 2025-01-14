//
//  PremiumShopView.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 26/11/2024.
//

import SwiftUI
import Kingfisher
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack {
            // Article Image with Text at the Top and Button at the Bottom
            ZStack(alignment: .top) {
                // Article Image
                KFImage(URL(string: article.imageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            
                .frame(maxWidth: 350, maxHeight: 300)
                .cornerRadius(50)
                .clipped()
                    
                // Text on top of the image
                
                    VStack {
                        Spacer()
                        
                        ZStack(alignment:.center){
                            
                            ShadowedText(text: article.title,font:.subheadline,weight:.bold,shadowedBackground: true)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .padding(.top,70)
                    .padding(.horizontal,20)
                    
                
                

                // Button at the bottom of the image
                VStack {
                    Spacer()
                    Button(action: {
                        // Open the article link in the browser
                        if let url = URL(string: article.link) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }) {
                        ZStack {
                            // Shadows for button text visibility
                            ShadowedText(text: "MORE", font: .caption, weight: .bold)
                        }
                        .frame(width: 200)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding()
            }
            .frame(height: 300)
            .cornerRadius(20)
            .shadow(radius: 5)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}



struct ShadowedText: View {
    let text: String
    let font: Font
    let weight: Font.Weight
    var shadowedBackground: Bool = false

    var body: some View {
        ZStack {
            // Shadows behind the main text
            Text(text)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.black)
                .offset(x: -1, y: -1)
            Text(text)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.black)
                .offset(x: 1, y: -1)
            Text(text)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.black)
                .offset(x: -1, y: 1)
            Text(text)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.black)
                .offset(x: 1, y: 1)

        
            // Main white text
            Text(text)
                .font(font)
                .fontWeight(weight)
                .foregroundColor(.white)
                .background(
                                shadowedBackground
                                    ? RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black.opacity(0.5)) // Semi-transparent black background
                                        .padding(.horizontal, -5) // Extend background beyond text horizontally
                                        .padding(.vertical, -5)
                                    : nil
                            )
                
        }
    }
}


