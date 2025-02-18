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
    
    /// ViewModel qui gère la logique et les données des annonces
    @StateObject private var viewModel: AdViewModel
    
    /// Stocker la préférence utilisateur pour utiliser UIKit ou SwiftUI pour la navigation
    @AppStorage("useUIKitNavigation") private var useUIKitNavigation: Bool = false
    
    /// Gèrer la sélection d'une annonce pour la navigation SwiftUI
    @State private var selectedAd: Ad?
    
    /// Définition des colonnes pour l'affichage en grille des annonces
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    /// Initialisation avec injection du `viewModel`
    public init(viewModel: AdViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            Group {
                /// Affichage d'un spinner pendant le chargement initial
                if viewModel.isLoading && viewModel.ads.isEmpty {
                    ProgressView("Chargement des annonces...")
                    
                    /// Affichage d'un message d'erreur si une erreur survient
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("❌ Erreur : \(error)")
                            .foregroundColor(.red)
                            .padding()
                        
                        /// Bouton permettant de relancer le chargement des annonces en cas d'erreur
                        Button("Réessayer") {
                            fetchAds()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    /// Affichage des annonces sous forme de grille
                } else {
                    VStack {
                        /// Liste des annonces affichées sous forme de grille
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                /// Parcours des annonces et affichage sous forme de cartes
                                ForEach(Array(viewModel.ads.enumerated()), id: \.element.id) { index, ad in
                                    ZStack {
                                        /// `NavigationLink` caché pour gérer la navigation SwiftUI
                                        NavigationLink(
                                            destination: AdDetailViewControllerWrapper(ad: ad),
                                            tag: ad,
                                            selection: $selectedAd
                                        ) {
                                            EmptyView()
                                        }
                                        .hidden() // Rendre invisible
                                        
                                        /// Carte représentant une annonce
                                        AdCardView(ad: ad)
                                        /// Détection du moment où l'utilisateur atteint la dernière annonce pour charger plus de données
                                            .onAppear {
                                                if viewModel.shouldLoadMore(ad: ad) {
                                                    Task {
                                                        await viewModel.fetchMoreAds()
                                                    }
                                                }
                                            }
                                        /// Gestion du clic pour la navigation SwiftUI ou UIKit
                                            .onTapGesture {
                                                if useUIKitNavigation {
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
            
            /// Rafraîchir les annonces en pull to refresh
            .refreshable {
                fetchAds()
            }
            
            /// Chargement initial des annonces au premier affichage
            .onAppear {
                if viewModel.ads.isEmpty {
                    fetchAds()
                }
            }
            
            /// Personnalisation de la barre de navigation
            .navigationTitle("Annonces")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    /// Charger les annonces
    private func fetchAds() {
        Task {
            await viewModel.fetchAds()
        }
    }
}

//struct AdListingView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdListingView()
//    }
//}
