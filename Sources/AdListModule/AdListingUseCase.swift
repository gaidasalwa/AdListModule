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


// Modèle de requête pour rechercher des annonces
struct SearchRequest: Codable {
    let type: [String]         // Types d'annonces (ex: don, prêt, etc.)
    let distance: Int          // Rayon de recherche en mètres
    let donationState: [String] // État de l'annonce (ex: "open", "reserved")
    let latitude: Double       // Coordonnées GPS de l'utilisateur (latitude)
    let universe: [String]     // Catégories d'objets recherchés
    let longitude: Double      // Coordonnées GPS de l'utilisateur (longitude)
    let after: String?         // ID pour la pagination (optionnel, permet de charger plus d'annonces)
}

// MARK: - Protocole FetchAdsUseCaseProtocol
public protocol FetchAdsUseCaseProtocol {
    func fetchAds(after: String?) async throws -> [Ad] // Fonction asynchrone qui retourne une liste d'annonces
}

public class FetchAdsUseCase: FetchAdsUseCaseProtocol {
    
    private let httpClient: HTTPClientProtocol // Client HTTP pour effectuer la requête réseau
    
    public init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    /// Récupèrer les annonces depuis l'API avec support de la pagination
    public func fetchAds(after: String? = nil) async throws -> [Ad] {
        
        // Coordonnées de l'utilisateur (à améliorer pour être dynamiques locationManager.userLocation)
        let latitude: Double =  44.8380691
        let longitude: Double = -0.5777678
        
        // Paramètres de la requête API sous forme de dictionnaire (pareil à améliorer en passant en paramètres dynamiques liés aux filtres de l'utilisateur
        var parameters: [String: Any] = [
            "type": ["donation"],                 // On recherche uniquement les dons
            "distance": 10000,                    // Rayon de 10 km
            "donationState": ["open", "reserved"],// Annonces ouvertes ou réservées
            "latitude": latitude,                 // Localisation de l'utilisateur
            "universe": ["object"],               // Filtrage par catégorie "objets"
            "longitude": longitude                // Localisation de l'utilisateur
        ]
        
        // Ajouter l'ID de la dernière annonce chargée pour récupérer les suivantes (pagination)
        if let after = after {
            parameters["after"] = after
        }
        
        // Convertir les paramètres en JSON pour l'envoyer dans le corps de la requête
        let bodyData = try JSONSerialization.data(withJSONObject: parameters)
        
        // Création de la requête HTTP via l'endpoint dédié
        let urlRequest = Endpoint.fetchAdList(body: bodyData).urlRequest
        
        do {
            // Envoyer la requête via le client HTTP et décodage de la réponse
            let ads: AdListResponse = try await httpClient.sendRequest(to: urlRequest)
            print(" Annonces reçues : \(ads)")
            
            // Transformer des annonces reçues en objets `Ad` utilisables par l'UI
            return ads.data.map {
                
                // Créer des objets `Location` pour calculer la distance
                let location = Location(latitude: latitude, longitude: longitude)
                let adLocation = Location(latitude: $0.location.latitude, longitude: $0.location.longitude)
                
                return Ad(
                    id: $0.id,                                         // Identifiant unique de l'annonce
                    imageUrl: $0.pictures.first?.squares128,           // Première image de l'annonce
                    createdSince: $0.creationDateMs.minutesSince(),    // Date de création formatée
                    distance: location.distance(to: adLocation),       // Distance entre l'annonce et l'utilisateur
                    title: $0.title,                                   // Titre de l'annonce
                    description: $0.description                        // Description de l'annonce
                )
            }
        } catch {
            // ❌ Gestion des erreurs
            print("Erreur : \(error)")
            throw error
        }
    }
}
