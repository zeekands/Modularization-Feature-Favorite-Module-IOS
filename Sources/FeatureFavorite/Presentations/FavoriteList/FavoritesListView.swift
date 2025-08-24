//
//  FavoritesListView.swift
//  FeatureFavorite
//
//  Created by zeekands on 04/07/25.
//


import SwiftUI
import SharedDomain // Untuk MovieEntity, TVShowEntity
import SharedUI     // Untuk LoadingIndicator, ErrorView, PosterImageView, ItemGridCell

public struct FavoritesListView: View {
  @StateObject private var viewModel: FavoritesListViewModel
  
  public init(viewModel: FavoritesListViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  public var body: some View {
    Group {
      if viewModel.isLoading {
        LoadingIndicator()
      } else if let errorMessage = viewModel.errorMessage {
        ErrorView(message: errorMessage, retryAction: viewModel.retryLoadFavorites)
      } else if viewModel.favoriteMovies.isEmpty && viewModel.favoriteTVShows.isEmpty {
        ContentUnavailableView("No Favorites Yet", systemImage: "star.fill")
      } else {
        favoritesContent
      }
    }
    .navigationTitle("Favorites")
    .onAppear {
      Task { await viewModel.loadFavorites() }
    }
    
  }
  
  // MARK: - Favorites Content View
  private var favoritesContent: some View {
    List {
      // MARK: - Favorite Movies
      Section("Favorite Movies") {
        if viewModel.favoriteMovies.isEmpty {
          Text("You haven't favorited any movies yet.")
            .foregroundColor(.textSecondary)
        } else {
          ForEach(viewModel.favoriteMovies) { movie in
            FavoriteMovieRowView(movie: movie, viewModel: viewModel)
              .onTapGesture {
                viewModel.navigateToMovieDetail(movieId: movie.id)
              }
              .swipeActions(edge: .leading) {
                Button {
                  Task { await viewModel.toggleFavorite(movie: movie) }
                } label: {
                  Label("Unfavorite", systemImage: "star.slash.fill")
                }
                .tint(.gray)
              }
          }
        }
      }
      
      // MARK: - Favorite TV Shows
      Section("Favorite TV Shows") {
        if viewModel.favoriteTVShows.isEmpty {
          Text("You haven't favorited any TV shows yet.")
            .foregroundColor(.textSecondary)
        } else {
          ForEach(viewModel.favoriteTVShows) { tvShow in
            FavoriteTVShowRowView(tvShow: tvShow, viewModel: viewModel)
              .onTapGesture {
                viewModel.navigateToTVShowDetail(tvShowId: tvShow.id)
              }
              .swipeActions(edge: .leading) {
                Button {
                  Task { await viewModel.toggleFavorite(tvShow: tvShow) }
                } label: {
                  Label("Unfavorite", systemImage: "star.slash.fill")
                }
                .tint(.gray)
              }
          }
        }
      }
    }
  }
}

// MARK: - Helper Views for Favorite Rows
// Pastikan Helper View ini public dan sesuai dengan kebutuhan Anda.
// Anda bisa menempatkannya di file terpisah jika Anda mau.

public struct FavoriteMovieRowView: View {
  public let movie: MovieEntity
  @ObservedObject public var viewModel: FavoritesListViewModel // Untuk aksi favorit
  
  public var body: some View {
    HStack {
      // Gunakan PosterImageView dari SharedUI
      PosterImageView(imagePath: movie.posterPath, imageType: .poster)
        .frame(width: 50, height: 75)
        .cornerRadius(8)
        .shadow(radius: 2)
      
      VStack(alignment: .leading) {
        Text(movie.title)
          .font(.headline)
          .foregroundColor(.textPrimary)
        Text(movie.overview ?? "")
          .font(.subheadline)
          .lineLimit(2)
          .foregroundColor(.textSecondary)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.textSecondary)
    }
    .padding(.vertical, 4)
  }
}

public struct FavoriteTVShowRowView: View {
  public let tvShow: TVShowEntity
  @ObservedObject public var viewModel: FavoritesListViewModel // Untuk aksi favorit
  
  public var body: some View {
    HStack {
      // Gunakan PosterImageView dari SharedUI
      PosterImageView(imagePath: tvShow.posterPath, imageType: .poster)
        .frame(width: 50, height: 75)
        .cornerRadius(8)
        .shadow(radius: 2)
      
      VStack(alignment: .leading) {
        Text(tvShow.name)
          .font(.headline)
          .foregroundColor(.textPrimary)
        Text(tvShow.overview ?? "")
          .font(.subheadline)
          .lineLimit(2)
          .foregroundColor(.textSecondary)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.textSecondary)
    }
    .padding(.vertical, 4)
  }
}
