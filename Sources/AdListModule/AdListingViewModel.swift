//
//  AdViewModel.swift
//  GeevTest
//
//  Created by Gaida Salwa on 10/02/2025.
//

import SwiftUI
import AppModels
import CoreModule
import AppCoordinatorModule

public class AdViewModel: ObservableObject {
    
    private var fetchAdsUseCase: FetchAdsUseCaseProtocol
    
    // Coordinateur UIKit pour la navigation vers les détails
    private var coordinator: UIKitCoordinator
    
    // Liste des annonces récupérées
    @Published var ads: [Ad] = []
    
    // Indique si une requête est en cours (affiche un spinner si true)
    @Published var isLoading = false
    
    // Indique s'il y a encore des annonces à charger (pagination)
    @Published var hasMoreAds = true
    
    // Stocke un message d'erreur s'il y a un problème de chargement
    @Published var errorMessage: String?
    
    // Stocke l'identifiant de la dernière annonce chargée (pour la pagination)
    private var after: String? = nil
    
    public init(
        fetchAdsUseCase: FetchAdsUseCaseProtocol,
        coordinator: UIKitCoordinator
    ) {
        self.fetchAdsUseCase = fetchAdsUseCase
        self.coordinator = coordinator
    }
    
    /// Récupérer les annonces depuis l'API
    @MainActor
    func fetchAds() async {
        guard !isLoading else { return } // Empêche plusieurs requêtes en même temps
        isLoading = true
        
        Task {
            do {
                // Appeler de l'API avec l'ID de la dernière annonce (`after`) pour la pagination
                let response = try await fetchAdsUseCase.fetchAds(after: after)
                
                if response.isEmpty {
                    print("Aucune nouvelle annonce reçue, stop pagination")
                    hasMoreAds = false // Plus rien à charger
                    return
                }
                
                // Ajouter les nouvelles annonces à la liste existante
                self.ads.append(contentsOf: response)
                
                // Mettre à jour `after` avec l'ID de la dernière annonce pour la pagination
                self.after = response.last?.id
                print("Mise à jour de after : \(self.after ?? "Aucun")")
                
            } catch {
                // Gestion des erreurs : on met à jour `errorMessage` pour l'afficher dans l'UI
                self.errorMessage = error.localizedDescription
                print("Erreur lors du chargement des annonces :", error)
            }
            
            isLoading = false // Fin du chargement
        }
    }
    
    /// Charger plus d'annonces quand l'utilisateur scrolle en bas de la liste
    @MainActor
    func fetchMoreAds() async {
        await fetchAds()
    }
    
    /// Recharger toutes les annonces (après un pull-to-refresh)
    @MainActor
    func refreshAds() async {
        after = nil // Réinitialise la pagination
        ads.removeAll() // Vide la liste avant de recharger
        await fetchAds()
    }
    
    /// Déterminer si on doit charger plus d'annonces en fonction de l'annonce affichée
    func shouldLoadMore(ad: Ad) -> Bool {
        guard hasMoreAds else { return false } // Stopper le chargement si plus d'annonces
        if let lastAd = ads.last, lastAd.id == ad.id {
            return true // Déclencher un chargement si on arrive sur la dernière annonce affichée
        }
        return false
    }
    
    /// Afficher les détails d'une annonce via UIKit (navigation avec le coordinateur)
    @MainActor
    func showAdDetail(ad: Ad) {
        coordinator.showAdDetail(ad: ad)
    }
}
