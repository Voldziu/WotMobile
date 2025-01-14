//
//  StatBox.swift
//  WotMobile
//
//  Created by Mikołaj Machalski on 09/12/2024.
//
import SwiftUI


struct StatBox: View {
    var title: String
    var value: String
    var color: Color = Color(.systemGray2)
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white) // wn8
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white) // wn8
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(color))
        .cornerRadius(8)
    }
}
