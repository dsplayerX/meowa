//
//  CatView.swift
//  Meowa
//
//  Created by Dumindu Sameendra on 2024-10-23.
//

import SwiftUI


struct CatDetailsView: View {
    var cat: BreedDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: {
                if let referenceImageID = cat.referenceImageID {
                    return URL(string: "https://cdn2.thecatapi.com/images/\(referenceImageID).jpg")
                } else {
                    return nil
                }
            }()) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 350, height: 350)
                        .cornerRadius(10)
                } else if phase.error != nil {
                    Image(systemName: "photo.badge.exclamationmark.fill").frame(width: 350, height: 350)
                } else {
                    ProgressView().frame(width: 350, height: 350)
                }
            }.padding()
            VStack(alignment: .leading, spacing: 10){
                Text(cat.name).font(.largeTitle).fontWeight(.bold)
                Text(cat.description).font(.body)
                Text("Temperament: \(cat.temperament)").font(.body)
                Text("From: \(cat.origin)").font(.body)
                Text("Weight(kg): \(cat.weight.metric)").font(.body)
                Text("Life Span(years): \(cat.lifeSpan)").font(.body)
                
            }.padding()
            
            
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
