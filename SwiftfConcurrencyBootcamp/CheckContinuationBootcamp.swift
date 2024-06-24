//
//  CheckContinuationBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 22/6/2567 BE.
//

import SwiftUI

class CheckContinuationBootcampNewworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        let urlRequest = URLRequest(url: url)
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data {
                    continuation.resume(returning: data)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if let image = UIImage(systemName: "heart.fill") {
                completionHandler(image)
            }
        }
    }
    
    func getHeartImageFromDatabase2() async -> UIImage {
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckContinuationBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckContinuationBootcampNewworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase2()
        /*
        networkManager.getHeartImageFromDatabase { [weak self] image in
            self?.image = image
        }
        */
    }
    
}

struct CheckContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    CheckContinuationBootcamp()
}
