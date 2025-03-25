//
//  MarvelHeroesView.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import SwiftUI

// MARK: - Marvel Heroes View

/// A view displaying a list of Marvel heroes, with support for navigation to hero details
/// and error handling in case of API failures.
struct MarvelHeroesView: View {
    @StateObject private var viewModel = MarvelHeroesViewModel()
  
    var body: some View {
        NavigationStack {
            VStack {
                content
            }
            .navigationTitle("Heroes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $viewModel.selectedCharacter) { character in
                MarvelHeroesDetailView(character: character)
            }
            .animation(.easeInOut, value: viewModel.errorMessage)
            .onAppear(perform: loadHeroes)
        }
    }
}

// MARK: - Private Extension

private extension MarvelHeroesView {
    /// The main content view displaying either a loading indicator, a list of heroes, or an error state.
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading Heroes...")
                .font(.headline)
        } else if !viewModel.characters.isEmpty {
            heroesListView
        } else {
            ErrorStateView(errorMessage: viewModel.errorMessage ?? "No Heroes Found", retryAction: loadHeroes)
                .transition(.opacity)
        }
    }
    
    // MARK: - Heroes List View
    
    /// A list view displaying all fetched Marvel heroes.
    var heroesListView: some View {
        List {
            ForEach(viewModel.characters, id: \ .id) { character in
                Button {
                    viewModel.selectedCharacter = character
                } label: {
                    MarvelCharacterView(character: character)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    // MARK: - Error State View
    
    /// A reusable error state view displayed when there is an issue fetching heroes.
    struct ErrorStateView: View {
        let errorMessage: String
        let retryAction: () -> Void
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.yellow)
                
                Text("Oops! Something went wrong.")
                    .font(.headline)
                
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: retryAction) {
                    Text("Retry")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
    }
    
    // MARK: - Load Heroes
    
    /// Triggers the hero fetch operation in the view model.
    private func loadHeroes() {
        viewModel.fetchCharacters()
    }
}

// MARK: - Preview

#Preview {
    MarvelHeroesView()
}
