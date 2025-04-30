//
//  MarvelHeroesDetailView.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import SwiftUI

// MARK: - Marvel Hero Detail View

/// Displays details about a selected Marvel character, including their image, description, and comics.
struct MarvelHeroesDetailView: View {
    let character: MarvelCharacter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                MarvelCharacterView(character: character)

                if !character.description.isEmpty {
                    descriptionView
                }
                comicsSectionView
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Description View

    /// Displays the character's description.
    private var descriptionView: some View {
        Text(character.description)
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding()
    }

    // MARK: - Comics Section View

    /// Displays either a list of comics or an empty state message.
    @ViewBuilder
    private var comicsSectionView: some View {
        if hasComics {
            comicsSection
        } else {
            emptyComicsView
        }
    }

    /// Checks if the character has associated comics.
    private var hasComics: Bool {
        !(character.comics?.items.isEmpty ?? true)
    }

    /// Displays a list of comics associated with the character.
    private var comicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            comicsHeader

            ForEach(character.comics?.items ?? [], id: \.resourceURI) { comic in
                ComicItemView(comic: comic)
            }
        }
        .padding()
    }

    // MARK: - Empty Comics View

    /// Displays a placeholder view when no comics are available.
    private var emptyComicsView: some View {
        VStack(spacing: 16) {
            Text("This hero has no comics")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Comics Header

    /// Displays a header for the comics section.
    private var comicsHeader: some View {
        Text("\(character.name) Comics")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

// MARK: - Comic Item View

/// Represents an individual comic in the comics section.
private struct ComicItemView: View {
    let comic: ComicItem

    var body: some View {
        HStack {
            Image(systemName: "book")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.red)

            Text(comic.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    MarvelHeroesDetailView(character: MarvelCharacter.example)
}
