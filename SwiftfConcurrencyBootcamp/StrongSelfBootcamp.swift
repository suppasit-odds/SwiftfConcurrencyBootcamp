//
//  StrongSelfBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 2/7/2567 BE.
//

import SwiftUI

final class StrongSelfDataService {
    
    func getData() async -> String {
        "Updated data!"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data: String = ""
    let dataService = StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>?] = []

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach { $0?.cancel() }
        myTasks = []
    }
    
    // This implies a strong reference.
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This is a strong reference.
    func updateData2() {
        Task {
            self.data = await dataService.getData()
        }
    }
    
    // This is a strong reference.
    func updateData3() {
        Task { [self] in
            self.data = await dataService.getData()
        }
    }
    
    // This is a weak reference.
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }

    // We don't needd to manager weak/strong
    // We can manage the task
    func updateData5() {
        someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // We can manage the task!
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task2)
    }
    
    // We purposely do not cancel tasks to keep strong references!
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    func updateData8() async {
        self.data = await self.dataService.getData()
    }

}

struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            // The .task{} will be automatically cancel, when
            // the view is disappear. So we do not need to hold
            // the weak reference to the object!
            .task {
                await viewModel.updateData8()
            }
    }
}

#Preview {
    StrongSelfBootcamp()
}
