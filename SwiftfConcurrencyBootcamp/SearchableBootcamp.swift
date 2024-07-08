//
//  SearchableBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 4/7/2567 BE.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese
}

final class RestaurantManager {
    
    func getAllRestuarant() async throws -> [Restaurant] {
        [
           Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
           Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
           Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
           Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
    }
    
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    let manager = RestaurantManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var showSearchSuggestion: Bool {
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .cuisine(let option):
                return option.rawValue.capitalized
            }
        }
    }
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] (searchText, searchScope) in
                self?.filteredRestaurant(searchText: searchText, currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filteredRestaurant(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty  else {
            filteredRestaurants = []
            searchScope = .all
            return
        }
        
        // Filter on search scope
        var restaurantInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case .cuisine(let option):
            restaurantInScope = allRestaurants.filter { $0.cuisine == option }
        }
        
        // Filter on searh text
        let search = searchText.lowercased()
        filteredRestaurants = restaurantInScope.filter {
            let titleContainsSearch = $0.title.lowercased().contains(search)
            let cuisineContainSearc = $0.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainSearc
        }
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestuarant()
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map { SearchScopeOption.cuisine(option: $0) }
        } catch {
            
        }
    }
    
    func getSearchSuggestion() -> [String] {
        guard showSearchSuggestion else {
            return []
        }
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard showSearchSuggestion else {
            return []
        }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .italian})
        }
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter { $0.cuisine == .japanese})
        }
        return suggestions
    }
    
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restuarant in
                    NavigationLink(value: restuarant) {
                        restaurantRow(restaurant: restuarant)
                    }
                }
            }
            .padding()
            
            // Text("ViewModel is searching: \(viewModel.isSearching.description)")
            // SearchChildView()
            
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search restaurants...")
)
        .searchScopes($viewModel.searchScope) {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        }
        .searchSuggestions {
            ForEach(viewModel.getSearchSuggestion(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { suggestion in
                NavigationLink(value: suggestion) {
                    Text(suggestion.title)
                }
                
            }
        }
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(Color.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary )
    }
}

struct SearchChildView: View {
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child View is searching: \(isSearching.description)")
    }
}

#Preview {
    NavigationStack {
        SearchableBootcamp()
    }
}
