//
//  MarvelHeroesViewModel.swift
//  MarvelXplorer
//
//  Created by Mitali Gondaliya on 12/02/25.
//

import Combine
import Foundation

class MarvelHeroesViewModel: ObservableObject {
    @Published var characters: [MarvelCharacter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables: Set<AnyCancellable> = []
    private let networkManager: APIClient
    private var hasLoadedData = false // Track if data is already loaded

    // MARK: - Initializer
    init(networkManager: APIClient = NetworkManager.init()) {
        self.networkManager = networkManager
    }

    // MARK: - Fetch Characters
    func fetchCharacters() {
        guard !hasLoadedData else { return }

        isLoading = true
        errorMessage = nil

        let endpoint = Endpoint.characters()

        networkManager.request(endpoint, responseType: MarvelResponse<MarvelCharacter>.self)
            .receive(on: DispatchQueue.main)
            .map { $0.data.results }
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] characters in
                self?.characters = characters
                self?.hasLoadedData = true
            })
            .store(in: &cancellables)
    }
}
