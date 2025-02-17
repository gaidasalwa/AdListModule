//
//  AdCardView.swift
//  Geev
//
//  Created by Gaida Salwa on 11/02/2025.
//


import SwiftUI
import AppModels
import Extensions

struct AdCardView: View {
    let ad: Ad
    
    var body: some View {
        VStack(alignment: .leading) {
            if let image = ad.imageUrl {
                AsyncImage(url: URL(string: image)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 150)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ad.title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(String(describing: ad.createdSince)) min")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(ad.distance) km")
                    }
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            .padding(4)
        }
        .frame(width: 170, height: 210) // Taille uniforme
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
