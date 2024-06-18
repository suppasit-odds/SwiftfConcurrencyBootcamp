//
//  DownloadImageAsync.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 18/6/2567 BE.
//

import SwiftUI
import Combine

class DownloadImageAsyncLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithrscaping(completionHanler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHanler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncLoader()
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        // Load the image with closure
        /*
        loader.downloadWithrscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
        */
        
        // Load the image with combine
        /*
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // No implementation
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
        */
        
        // Load the image with async/await
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
    
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task { // We actually start the task here, to get into the concurrency mode.
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
