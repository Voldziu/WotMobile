//
//  Scrapper.swift
//  WOTMOBILEE
//
//  Created by Mikołaj Machalski on 10/01/2025.
//


import Foundation
import SwiftSoup

struct Article {
    let id = UUID()
    let title: String
    let link: String
    let imageURL: String
}


func fetchHTML(from url: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: url) else {
        print("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching HTML: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data, let html = String(data: data, encoding: .utf8) else {
            print("Failed to decode HTML")
            completion(nil)
            return
        }
        
        completion(html)
    }
    task.resume()
}

func scrapeArticles(from html: String, completion: @escaping ([Article]) -> Void) {
    do {
        let document = try SwiftSoup.parse(html)
        
        // Target the div with class "cards-news-widget_content"
        let articlesContainer = try document.select("div.cards-news-widget_content").first()
        var articlesList: [Article] = []
        
        if let articlesContainer = articlesContainer {
            // Select all article elements inside the container
            let articles = try articlesContainer.select("article")
            
            for article in articles {
                // Extract href attribute (link to the article)
                let href = try article.select("a").attr("href")
                let fullLink = "https://worldoftanks.eu\(href)"
                
                // Extract title from h3 element with class "card_title"
                let title = try article.select("h3.card_title").text()
                
                // Extract image URL from the style attribute of the div with class "card_preview"
                let imageStyle = try article.select("div.card_preview").attr("style")
                let imageURL = extractImageURL(from: imageStyle)
                
                // Create an Article object
                let articleData = Article(title: title, link: fullLink, imageURL: imageURL)
                articlesList.append(articleData)
            }
        }
        
        // Pass the list of articles back via the completion handler
        completion(articlesList)
        
    } catch {
        print("Error parsing HTML: \(error)")
        completion([])
    }
}

func extractImageURL(from style: String) -> String {
    
    let pattern = #"url\('(.*?)'\)"#
    if let regex = try? NSRegularExpression(pattern: pattern),
       let match = regex.firstMatch(in: style, range: NSRange(style.startIndex..., in: style)) {
        if let range = Range(match.range(at: 1), in: style) {
            return "https:" + style[range] // Add "https:" to the extracted URL
        }
    }
    return "No image URL"
}


