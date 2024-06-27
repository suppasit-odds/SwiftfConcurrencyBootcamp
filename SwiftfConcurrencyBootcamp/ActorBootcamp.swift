//
//  ActorBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 26/6/2567 BE.
//

import SwiftUI

// 1. What is the problem that actors are solving?
// 2. How was this problem solveed prior to actors?
// 3. Actors can solve the problem!

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    // Soving data race with queue
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ returnedTitle: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() { }
    
    var data: [String] = []
    nonisolated let myRandomText: String = "jlkjKLaj;kdf∂fdkllljjccc"
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
        // NOTE: You cannnot access isolated data or function form
        //       from a nonisolated function.
        "NEW DATA"
    }
    
}

struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    // let manager = MyDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let newString = manager.getSavedData()
            let nonIsolatedString = manager.myRandomText
            /*
            Task {
                let newString = await manager.getSavedData()
            }
            */
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            /*
            DispatchQueue.global(qos: .background).async {
                manager.getRandomData { title in
                    if let title {
                        DispatchQueue.main.async {
                            self.text = title
                        }
                    }
                }
            }
            */
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    // let manager = MyDataManager.instance    @State private var text: String = ""
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            /*
            DispatchQueue.global(qos: .default).async {
                manager.getRandomData { title in
                    if let title {
                        DispatchQueue.main.async {
                            self.text = title
                        }
                    }
                }
            }
            */
        }
    }
}

struct ActorBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorBootcamp()
}
