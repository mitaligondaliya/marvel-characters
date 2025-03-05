//
//  MarvelHeroesView.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import Foundation
import SwiftUI

struct MarvelHeroesView: View {
    @StateObject private var viewModel = MarvelHeroesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                content
            }
            .alert(
                "Error",
                isPresented: .constant(viewModel.errorMessage != nil),
                actions: {
                    Button("OK", role: .cancel) {
                        viewModel.errorMessage = nil
                    }
                },
                message: {
                    Text(viewModel.errorMessage ?? "")
                }
            )
            .navigationTitle("Heroes")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.fetchCharacters()
        }
    }
}

private extension MarvelHeroesView {
    // MARK: - Main Content View (List of Heroes)
    var content: some View {
        Group {
            if viewModel.characters.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.characters, id: \.id) { character in
                        NavigationLink(destination: MarvelHeroesDetailView(character: character)) {
                            MarvelCharacterView(character: character)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .padding(.horizontal, -20)
            }
        }
    }

    var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No superheroes found")
                .font(.title2)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MarvelHeroesView()
}
