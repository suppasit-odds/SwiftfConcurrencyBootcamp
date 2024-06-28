//
//  GlobalActorBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 28/6/2567 BE.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
// @globalActor struct MyFirstGlobalActor {

    // When accessing the global actor,
    // we need to access it through the shared instance.
    static var shared = MyNewDataManager()
    
}

// Thread safe
actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five", "Six"]
    }
    
}

class GlobalActorBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    // @MainActor func getData() {
    @MyFirstGlobalActor func getData() {
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run {
                // The `dataArray` affects the UI.
                // So we need to update this variable on the main thread.
                self.dataArray = data
            }
        }
    }
    
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorBootcamp()
}
