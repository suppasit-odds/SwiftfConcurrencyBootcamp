//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 17/6/2567 BE.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: (any Error)?) {
        if isActive {
            return ("New TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New TEXT!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
        throw URLError(.badServerResponse)

//        if isActive {
//            return "New TEXT!"
//        } else {
//            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    @Published var text: String = "Starting text."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle() {
        /*
         let newValue = manager.getTitle()
         if let newTitle = newValue.title {
         text = newTitle
         } else if let error = newValue.error {
         text = error.localizedDescription
         }
         */
        
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            text = newTitle
        case .failure(let error):
            text = error.localizedDescription
        }
        */
        
        /*
        let newTitle = try? manager.getTitle3()
        if let newTitle {
            text = newTitle
        }
        */

        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle {
                text = newTitle
            }
            
            let finalTitle = try manager.getTitle4()
            text = finalTitle
        } catch let error {
            text = error.localizedDescription
        }
    }
    
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
