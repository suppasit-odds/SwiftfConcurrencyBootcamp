//
//  AsyncLetBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 20/6/2567 BE.
//

import SwiftUI

struct AsyncLetBootcamp: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let 🥳")
            .task {
                do {
                    async let fetchImage1 = fetchImage()
                    async let fetchTitle1 = fetchTitle()
                    
                    let (image, title) = await (try fetchImage1, fetchTitle1)
                    self.images.append(image)
                    
//                    async let fetchImage2 = fetchImage()
//                    async let fetchImage3 = fetchImage()
//                    async let fetchImage4 = fetchImage()
//                    
//                    let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                    self.images.append(contentsOf: [image1, image2, image3, image4])

//                    let image1 = try await fetchImage()
//                    self.images.append(image1)
//                    
//                    let image2 = try await fetchImage()
//                    self.images.append(image2)
//                    
//                    let image3 = try await fetchImage()
//                    self.images.append(image3)
//                    
//                    let image4 = try await fetchImage()
//                    self.images.append(image4)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchTitle() async -> String {
        return "NEW TITLE"
    }
    
    func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

#Preview {
    AsyncLetBootcamp()
}
