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

//@MainActor
final class AdViewModel: ObservableObject {
    private var fetchAdsUseCase: FetchAdsUseCaseProtocol
    private var coordinator: UIKitCoordinator
    @Published var ads: [Ad] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var after: String? = nil
    
    init(
        fetchAdsUseCase: FetchAdsUseCaseProtocol,
        coordinator: UIKitCoordinator
    ) {
        self.fetchAdsUseCase = fetchAdsUseCase
        self.coordinator = coordinator
    }
    
    @MainActor
    func fetchAds() async {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let response = try await fetchAdsUseCase.fetchAds(after: "67462abca4ddfca45fe05311")
                ads.append(contentsOf: response)
                ads.sort { $0.createdSince < $1.createdSince } // afficher le plus récent en premier
            } catch {
                self.errorMessage = error.localizedDescription
                print("Erreur lors du chargement des annonces :", error)
            }
            isLoading = false
        }
    }
    
    @MainActor
    func fetchMoreAds() async {
        await fetchAds()
    }
    
    @MainActor
    func refreshAds() async {
        after = nil
        ads.removeAll()
        await fetchAds()
    }
    
    func shouldLoadMore(ad: Ad) -> Bool {
        return ads.last == ad && !isLoading
    }
    
    @MainActor
    func showAdDetail(ad: Ad) {
        coordinator.showAdDetail(ad: ad)
    }
}
