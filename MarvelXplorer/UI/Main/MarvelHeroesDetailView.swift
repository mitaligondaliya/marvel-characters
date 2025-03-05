//
//  MarvelHeroesDetailView.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import Foundation
import SwiftUI

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
    private var descriptionView: some View {
        Text(character.description)
            .font(.subheadline)
            .foregroundColor(.primary)
            .padding(.horizontal)
    }

    // MARK: - Comics Section View
    private var comicsSectionView: some View {
        Group {
            if let comics = character.comics?.items, !comics.isEmpty {
                comicsSection(comics: comics)
            } else {
                emptyComicsView
            }
        }
        .padding(.horizontal)
    }

    private func comicsSection(comics: [ComicItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            comicsHeader

            ForEach(comics, id: \.resourceURI) { comic in
                comicItemView(comic: comic)
            }
        }
        .padding(.vertical)
        .cornerRadius(12)
    }

    // MARK: - Comic Item View
    private func comicItemView(comic: ComicItem) -> some View {
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
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .shadow(radius: 4)
        )
    }

    // MARK: - Empty Comics View
    private var emptyComicsView: some View {
        VStack(spacing: 16) {
            Text("This hero has no comics")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Comics Header
    private var comicsHeader: some View {
        Text("\(character.name) Comics")
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .foregroundColor(.primary)
    }
}

#Preview {
    MarvelHeroesDetailView(character: MarvelCharacter.example)
}
