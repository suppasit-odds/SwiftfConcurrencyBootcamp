//
//  TaskBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 19/6/2567 BE.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    private let urlString = "https://picsum.photos/200"

    func fetchImage() async {
        try? await Task.sleep(for: .seconds(5))
//        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: urlString) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED SUCCESSFULLY!!!")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchImage2() async {
        do {
            guard let url = URL(string: urlString) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image2 = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

struct TaskBootcampHomeViw: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("CLICK ME! 😀") {
                    TaskBootcamp()
                }
            }
        }
    }
}


struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var  fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        // With .task we cannot cancel the task
        /*
        .onDisappear {
            fetchImageTask?.cancel()
        }
        */
        // We can use .task to instead of .onAppear
        /*
        .onAppear {
            // Running multiple tasks in the same time!
            /*
            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage()
            }
            Task {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage2()
            }
            */
            
            // Running multiple tasks with different priorities
            /*
            Task(priority: .high) {
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await Task.yield()
                print("high: \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                print("userInitiated: \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                print("medium \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .low) {
                print("low: \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .utility) {
                print("utility: \(Thread.current) : \(Task.currentPriority)")
            }
            Task(priority: .background) {
                print("background: \(Thread.current) : \(Task.currentPriority)")
            }
            */

            // Child task will inherit all meta-data from parent task.
            /*
            Task(priority: .low) {
                print("low: \(Thread.current) : \(Task.currentPriority)")
                
                Task {
                    print("low2: \(Thread.current) : \(Task.currentPriority)")
                }
            }
            */
            
            // Child task can have different priority from the parent using detach
            // If possible, please avoid using it!!!!
            /*
            Task(priority: .low) {
                print("low: \(Thread.current) : \(Task.currentPriority)")
                
                Task.detached {
                    print("detached: \(Thread.current) : \(Task.currentPriority)")
                }
            }
            */
            
            // Cancel Task
            fetchImageTask = Task {
                await viewModel.fetchImage()
            }
        }
        */
    }
}

#Preview {
    TaskBootcampHomeViw()
//    TaskBootcamp()
}
