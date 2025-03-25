//
//  MarvelCharacterView.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import SwiftUI

// MARK: - Marvel Character View

/// A view displaying a Marvel character's image and name.
struct MarvelCharacterView: View {
    let character: MarvelCharacter

    var body: some View {
        VStack(spacing: 0) {
            imageView
        }
    }

    // MARK: - Image View

    /// Displays the character's image or a placeholder if unavailable.
    @ViewBuilder
    private var imageView: some View {
        if let url = character.thumbnail.url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .accessibilityLabel(character.name)
                    .accessibilityAddTraits(.isImage)
                    .clipped()
                    .overlay(alignment: .bottom) {
                        infoView
                    }
            } placeholder: {
                placeholderImage
            }
        } else {
            placeholderImage
        }
    }

    /// Placeholder image displayed when no character image is available.
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFill()
            .foregroundColor(.gray)
            .opacity(0.3)
    }

    // MARK: - Info View

    /// Displays the character's name over the image.
    var infoView: some View {
        HStack {
            Text(character.name)
                .font(.headline)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 40)
                .accessibilityLabel("Name: \(character.name)")
        }
        .background(Color.black.opacity(0.75))
    }
}

// MARK: - Preview

#Preview {
    MarvelCharacterView(
        character: MarvelCharacter.example
    )
}
