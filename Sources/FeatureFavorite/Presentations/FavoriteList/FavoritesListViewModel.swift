//
//  FavoritesListViewModel.swift
//  FeatureFavorite
//
//  Created by zeekands on 04/07/25.
//


import Foundation
import SharedDomain // Untuk MovieEntity, TVShowEntity, Use Cases Favorit, AppNavigatorProtocol
import SharedUI     // Untuk LoadingIndicator, ErrorView
import SwiftUI      // Untuk ObservableObject

@MainActor
public final class FavoritesListViewModel: ObservableObject {
    @Published public var favoriteMovies: [MovieEntity] = []
    @Published public var favoriteTVShows: [TVShowEntity] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let getFavoriteMoviesUseCase: GetFavoriteMoviesUseCaseProtocol
    private let getFavoriteTVShowsUseCase: GetFavoriteTVShowsUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol // Use case gabungan untuk toggle favorite
    
    private let appNavigator: AppNavigatorProtocol

    public init(
        getFavoriteMoviesUseCase: GetFavoriteMoviesUseCaseProtocol,
        getFavoriteTVShowsUseCase: GetFavoriteTVShowsUseCaseProtocol,
        toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
        appNavigator: AppNavigatorProtocol
    ) {
        self.getFavoriteMoviesUseCase = getFavoriteMoviesUseCase
        self.getFavoriteTVShowsUseCase = getFavoriteTVShowsUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.appNavigator = appNavigator

        Task { @MainActor in
            await loadFavorites()
        }
    }

    public func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        do {
            self.favoriteMovies = try await getFavoriteMoviesUseCase.execute()
            self.favoriteTVShows = try await getFavoriteTVShowsUseCase.execute()
        } catch {
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            print("Error loading favorites: \(error)")
        }
        isLoading = false
    }
    
    public func toggleFavorite(movie: MovieEntity) async {
        do {
            try await toggleFavoriteUseCase.execute(movieId: movie.id, isFavorite: !movie.isFavorite)
            await loadFavorites() // Muat ulang daftar favorit untuk update UI
        } catch {
            errorMessage = "Failed to toggle movie favorite: \(error.localizedDescription)"
            print("Error toggling movie favorite: \(error)")
        }
    }
    
    public func toggleFavorite(tvShow: TVShowEntity) async {
        do {
            try await toggleFavoriteUseCase.execute(tvShowId: tvShow.id, isFavorite: !tvShow.isFavorite)
            await loadFavorites() // Muat ulang daftar favorit untuk update UI
        } catch {
            errorMessage = "Failed to toggle TV Show favorite: \(error.localizedDescription)"
            print("Error toggling TV Show favorite: \(error)")
        }
    }

    // MARK: - Navigasi
    public func navigateToMovieDetail(movieId: Int) {
      appNavigator.navigate(to: .movieDetail(movieId: movieId), inTab: .favorites)
    }
    
    public func navigateToTVShowDetail(tvShowId: Int) {
      appNavigator.navigate(to: .tvShowDetail(tvShowId: tvShowId), inTab: .favorites) 
    }
    
    public func retryLoadFavorites() {
        Task { @MainActor in
            await loadFavorites()
        }
    }
}
