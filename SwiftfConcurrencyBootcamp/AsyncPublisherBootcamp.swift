//
//  AsyncPublisherBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 2/7/2567 BE.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Banan")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Orange")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Watermelon")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Grape")
    }
    
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    private let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscriber()
    }
    
    private func addSubscriber() {
        Task {
            await MainActor.run {
                self.dataArray = ["ONE"]
            }
            
            for await value in manager.$myData.values {
                await MainActor.run {
                    // self.dataArray = value
                }
            }
            
            await MainActor.run {
                self.dataArray = ["TWO"]
            }
            
        }
        /*
        manager.$myData
            .receive(on: DispatchQueue.main)
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellables)
        */
    }

    func start() async {
        await manager.addData()
//        dataArray = await manager.myData
    }
    
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
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
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
