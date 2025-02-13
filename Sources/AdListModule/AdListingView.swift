//
//  AdListingView.swift
//  GeevTest
//
//  Created by Gaida Salwa on 10/02/2025.
//

import SwiftUI
import AppModels
import AdDetailsModule
import CoreModule
import AppCoordinatorModule

public struct AdListingView: View {
    @StateObject private var viewModel = AdViewModel(
        fetchAdsUseCase: FetchAdsUseCase(httpClient: HTTPClient()),
        coordinator: UIKitCoordinator(navigationController: UINavigationController())
    )
    @State private var useUIKitCoordinator = false // ✅ Choix de navigation
    @State private var selectedAd: Ad?
    
    // Définition des colonnes de la grille
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Chargement des annonces...") // 🔄 Affichage du spinner
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("❌ Erreur : \(error)")
                            .foregroundColor(.red)
                            .padding()
                        Button("Réessayer") {
                            fetchAds()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack {
                        // ✅ Toggle pour choisir la navigation
                        Toggle("Utiliser UIKit Coordinator", isOn: $useUIKitCoordinator)
                            .padding()
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(viewModel.ads, id: \.id) { ad in
                                    ZStack {
                                        // ✅ NavigationLink caché
                                        NavigationLink(
                                            destination: AdDetailViewControllerWrapper(ad: ad),
                                            tag: ad,
                                            selection: $selectedAd
                                        ) {
                                            EmptyView()
                                        }
                                        .hidden() // Rendre invisible
                                        AdCardView(ad: ad)
                                            .onAppear {
                                                if viewModel.shouldLoadMore(ad: ad) {
                                                    Task {
                                                        await viewModel.fetchMoreAds()
                                                    }
                                                }
                                            }
                                            .onTapGesture {
                                                if useUIKitCoordinator {
                                                    viewModel.showAdDetail(ad: ad) // Navigation UIKit
                                                } else {
                                                    selectedAd = ad // Navigation SwiftUI
                                                }
                                            }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            
            .refreshable {
                fetchAds()
            }
            .onAppear {
                fetchAds()
            }
            .navigationTitle("Annonces")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func fetchAds() {
        Task {
            await viewModel.fetchAds()
        }
    }
}
