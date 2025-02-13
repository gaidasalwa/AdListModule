//
//  AdListingUseCase.swift
//  GeevTest
//
//  Created by Gaida Salwa on 10/02/2025.
//

import Foundation
import CoreModule
import AppModels
import Extensions
import Factory

struct SearchRequest: Codable {
    let type: [String]
    let distance: Int
    let donationState: [String]
    let latitude: Double
    let universe: [String]
    let longitude: Double
    let after: String? // Pour la pagination (optionnel)
}

public protocol FetchAdsUseCaseProtocol {
    func fetchAds(after: String?) async throws -> [Ad]
}

public class FetchAdsUseCase: FetchAdsUseCaseProtocol {
    private let httpClient: HTTPClientProtocol
    
    public init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    public func fetchAds(after: String? = nil) async throws -> [Ad] {
        let latitude: Double =  44.8380691 // à ajouter en paramètres
        let longitude: Double = -0.5777678 // à ajouter en paramètres
        let parameters: [String: Any] = [
            "type": ["donation"],
            "distance": 10000,
            "donationState": ["open", "reserved"],
            "latitude": latitude,
            "universe": ["object"],
            "longitude": longitude
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: parameters)
        let urlRequest = Endpoint.fetchAdList(body: bodyData).urlRequest
        do {
            let ads: AdListResponse = try await httpClient.sendRequest(to: urlRequest)
            print("✅ Annonces reçues : \(ads)")
            return ads.data.map {
                let location = Location(latitude: latitude, longitude: longitude)
                let adLocation = Location(latitude: $0.location.latitude, longitude: $0.location.longitude)
                return Ad(
                    id: $0.id,
                    imageUrl: $0.pictures.first?.squares128,
                    createdSince: $0.creationDateMs.minutesSince(),
                    distance: location.distance(to: adLocation),
                    title: $0.title,
                    description: $0.description
                )
            }
        } catch {
            print("❌ Erreur : \(error)")
            throw error
        }
    }
}
