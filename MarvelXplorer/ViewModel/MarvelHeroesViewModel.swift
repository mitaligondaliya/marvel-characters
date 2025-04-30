//
//  MarvelHeroesViewModel.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import Combine
import Foundation

// MARK: - Marvel Heroes View Model

/// ViewModel responsible for fetching and managing Marvel characters.
class MarvelHeroesViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var characters: [MarvelCharacter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCharacter: MarvelCharacter?

    // MARK: - Private Properties

    /// Set to store Combine subscriptions to avoid memory leaks.
    private var cancellables: Set<AnyCancellable> = []

    /// API client responsible for fetching Marvel characters.
    private let networkManager: APIClient

    /// Tracks if characters have already been fetched to prevent duplicate requests.
    var hasFetchedCharacters = false

    // MARK: - Initializer

    /// Initializes the ViewModel with a network manager.
    /// - Parameter networkManager: The API client responsible for fetching data.
    init(networkManager: APIClient = NetworkManager.init()) {
        self.networkManager = networkManager
    }

    // MARK: - Deinitializer

    /// Cancels all active subscriptions when the ViewModel is deallocated.
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    // MARK: - Fetch Characters

    /// Fetches Marvel characters from the API.
    func fetchCharacters() {
        guard !hasFetchedCharacters else { return }

        hasFetchedCharacters = true
        isLoading = true
        errorMessage = nil

        networkManager.request(.characters, responseType: MarvelResponse<MarvelCharacter>.self)
            .receive(on: DispatchQueue.main)
            .map { $0.data.results }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure = completion {
//                    self.hasFetchedCharacters = false // Reset early if request fails
//                    self.errorMessage = error.errorDescription ?? error.localizedDescription
                    self.hasFetchedCharacters = false // Retry allowed later
                    self.errorMessage = "API failed, showing offline data."
                    self.characters = self.loadDummyCharacters()
                }
            }, receiveValue: { [weak self] characters in
                guard let self = self else { return }

                let previousSelectionID = self.selectedCharacter?.id
                self.characters = characters
                self.selectedCharacter = self.characters.first(where: { $0.id == previousSelectionID })
            })
            .store(in: &cancellables)
    }

    private func loadDummyCharacters() -> [MarvelCharacter] {
        guard let url = Bundle.main.url(forResource: "DummyCharacters", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let response = try? JSONDecoder().decode(MarvelResponse<MarvelCharacter>.self, from: data) else {
            return []
        }
        return response.data.results
    }
}
