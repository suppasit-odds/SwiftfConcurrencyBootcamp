//
//  SendableBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 28/6/2567 BE.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyUserInfo) {
        
    }
    
}

struct MyUserInfo: Sendable {
    var name: String
}

// We can use @unchecked keyword to tell the compiler to stop report the error.
// But still need to make the class thread safe!!!
final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyUserInfo(name: "info")
        
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel  = SendableBootcampViewModel()
    
    var body: some View {
        Text("Hello, World!")
            .task {
               
            }
    }
}

#Preview {
    SendableBootcamp()
}
