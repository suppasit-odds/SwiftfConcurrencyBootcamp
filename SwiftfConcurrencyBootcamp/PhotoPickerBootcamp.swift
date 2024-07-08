//
//  PhotoPickerBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 8/7/2567 BE.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }

    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        Task {
            /*
             if let data = try? await selection.loadTransferable(type: Data.self),
             let uiImage = UIImage(data: data) {
                self.selectedImage = uiImage
             }
            */
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    images.append(uiImage)
                }
            }
            
            selectedImages = images
        }
    }
    
}

struct PhotoPickerBootcamp: View {
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the photo picker!")
                    .foregroundStyle(Color.red)
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                                .frame(width: 50, height: 50)
                                .shadow(radius: 10)
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("Open the photo picker!")
                    .foregroundStyle(Color.red)
            }

        }
    }
}

#Preview {
    PhotoPickerBootcamp()
}
