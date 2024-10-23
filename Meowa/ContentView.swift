//
//  ContentView.swift
//  Meowa
//
//  Created by Dumindu Sameendra on 2024-10-23.
//

import SwiftUI


struct BreedDTO: Codable, Hashable {
    let weight: WeightDTO
    let id, name: String
    let cfaURL: String?
    let vetstreetURL: String?
    let vcahospitalsURL: String?
    let temperament, origin, countryCodes, countryCode: String
    let description, lifeSpan: String
    let indoor, lap: Int?
    let altNames: String?
    let adaptability, affectionLevel, childFriendly, dogFriendly: Int
    let energyLevel, grooming, healthIssues, intelligence: Int
    let sheddingLevel, socialNeeds, strangerFriendly, vocalisation: Int
    let experimental, hairless, natural, rare: Int
    let rex, suppressedTail, shortLegs: Int
    let wikipediaURL: String?
    let hypoallergenic: Int?
    let referenceImageID: String?

    enum CodingKeys: String, CodingKey {
        case weight, id, name
        case cfaURL = "cfa_url"
        case vetstreetURL = "vetstreet_url"
        case vcahospitalsURL = "vcahospitals_url"
        case temperament, origin
        case countryCodes = "country_codes"
        case countryCode = "country_code"
        case description
        case lifeSpan = "life_span"
        case indoor, lap
        case altNames = "alt_names"
        case adaptability
        case affectionLevel = "affection_level"
        case childFriendly = "child_friendly"
        case dogFriendly = "dog_friendly"
        case energyLevel = "energy_level"
        case grooming
        case healthIssues = "health_issues"
        case intelligence
        case sheddingLevel = "shedding_level"
        case socialNeeds = "social_needs"
        case strangerFriendly = "stranger_friendly"
        case vocalisation, experimental, hairless, natural, rare, rex
        case suppressedTail = "suppressed_tail"
        case shortLegs = "short_legs"
        case wikipediaURL = "wikipedia_url"
        case hypoallergenic
        case referenceImageID = "reference_image_id"
    }
}

struct WeightDTO: Codable, Hashable {
    let imperial, metric: String
}

struct ContentView: View {
    @State var allBreedsData: [BreedDTO] = []
    @State var isLoading: Bool = true
    
    @State var searchResults: [BreedDTO] = []
    @State var searchQuery: String = ""

    var filteredBreeds: [BreedDTO] {
            if searchQuery.isEmpty {
                return allBreedsData
            } else {
                return searchResults
            }
        }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView().scaleEffect(2.0)
            } else {
                Text("Meowa").font(.largeTitle).fontWeight(.bold)
                
                NavigationStack {
                    List(filteredBreeds, id: \.self) { cat in
                        NavigationLink(destination: CatDetailsView(cat: cat)) {
                            
                            HStack {
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
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                    } else if phase.error != nil {
                                        Image(systemName: "photo.badge.exclamationmark.fill").frame(width: 100, height: 100)
                                    } else {
                                        ProgressView().frame(width: 100, height: 100)
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text(cat.name).font(.headline)
                                    Text(cat.temperament).font(.subheadline)
                                }
                            }
                        }
                    }
                }.listStyle(PlainListStyle())
                /// Search UI
                .searchable(
                        text: $searchQuery,
                          placement: .automatic,
                          prompt: "Search for a cat"
                      )
                .textInputAutocapitalization(.never)
                
                /// Filtering
                .onChange(of: searchQuery) {
                    self.fetchSearchResults(for: searchQuery)
                }
                
                /// Search empty state
                .overlay {
                    if filteredBreeds.isEmpty {
                        ContentUnavailableView(
                            "Cat missing!",
                            systemImage: "magnifyingglass",
                            description: Text("No results for **\\(searchQuery)**")
                        )
                    }
                }
            }
        }
        .onAppear {
            Task {
                await fetchBreeds()
            }
        }
    }
    
    func fetchBreeds() async {
        isLoading = true
        // Create URL
        let url = URL(string: "https://api.thecatapi.com/v1/breeds")
        
        guard let unwrappedUrl = url else {
            print("Invalid URL")
            return
        }
        
        // Initialize URL session
        do {
            let (data, response) = try await URLSession.shared.data(from: unwrappedUrl)

            // Check if valid response
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response.")
                return
            }

            // Decode data as an array of BreedDTO
            let decodedData = try JSONDecoder().decode([BreedDTO].self, from: data)
//            print(decodedData)
            allBreedsData = decodedData
            isLoading = false
            print("Fetched successfully")
                 
        } catch {
            print("Something went wrong: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    private func fetchSearchResults(for query: String) {
            searchResults = allBreedsData.filter { cat in
                cat.name
                    .lowercased()
                    .contains(searchQuery)
            }
        }
}


#Preview {
    ContentView()
}
