//
//  ObservableBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 9/7/2567 BE.
//

import SwiftUI

actor TitleDatabase {
    
    func getNewtitle() -> String {
        "Some new title!"
    }
    
}

@Observable final class ObservableViewModel: ObservableObject {
    
    @ObservationIgnored let database = TitleDatabase()
    @MainActor var title: String = "Starting title"
    
    // To make the whole function run on the main thread.
    // 1. We can use @MainActor
    /*
    @MainActor func updateTitle() async {
        title = await database.getNewtitle()
        print(Thread.current)
    }
    */
    
    // 2. update the variable on the main thread using MainActor.run()
    /*
    func updateTitle() async {
        let title = await database.getNewtitle()
        await MainActor.run {
            self.title = title
            print(Thread.current)
        }
    }
    */
    
    // 3. run on the task of the main
    func updateTitle() {
        Task { @MainActor in
            self.title = await database.getNewtitle()
            print(Thread.current)
        }
    }

}

struct ObservableBootcamp: View {
    
    @StateObject private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp()
}
