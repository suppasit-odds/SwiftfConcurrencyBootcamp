//
//  StructClassActorBootcamp.swift
//  SwiftfConcurrencyBootcamp
//
//  Created by Suppasit chuwatsawat on 24/6/2567 BE.
//

import SwiftUI

/*
Links:
 https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct/
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/
 
 VALUE TYPES:
 - Struct, Enum, String, Integer
 - Stored in the Stack
 - Faster
 - Thread safe
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - Not thread safe by default
 - When you assign or pass reference type a new reference to original instance will be created (pointer)

 -----------------------------

 STACK:
 - Stored Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has its own stack
 
 HEAP:
 - Store Reference Type
 - Shared across threads!

 -----------------------------

 STRUCT:
 - Base on VALUEs
 - Can be mutated
 - Store in the Stack!
 
 CLASS:
 - Base on REFERENCES (INSTANCES)
 - Stored in the Heap
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!

 -----------------------------
 
 Structs: Data Models, Views
 Class: ViewModels
 Actor: Shared 'Manager' and 'Data Store'


 */

actor StructClassActorBootcampDataManager {
    
    func getDataFromDatabase() {
        
    }
    
}

class StructClassActorBootcampViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    init() {
        print("ViewModel INIT")
    }
}

struct StructClassActorBootcamp: View {
    
    // When using @StateObject, the object will persist while the view is rerendering.
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
            .onAppear {
//                runTest()
            }
    }
}

struct StructClassActorBootcampHomeView: View {
    
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

#Preview {
    StructClassActorBootcamp(isActive: false)
}

extension StructClassActorBootcamp {
    
    private func runTest() {
        print("Test Started!")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorTest1()

//        structTest2()
//        printDivider()
//        classTest2()
    }
    
    private func printDivider() {
        print("""
        
        -----------------------------
        
        """)
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "Starting title")
        print("objectA: ", objectA.title)
        
        print("Pass the value of objectA to objectB.")
        var objectB = objectA
        print("objectB: ", objectB.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed.")
        
        print("objectA: ", objectA.title)
        print("objectB: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title!")
        print("objecvtA: ", objectA.title)

        print("Pass the REFERENCE of objectA to objectB.")
        let objectB = objectA
        print("objecvtB: ", objectA.title)
        
        objectB.title = "Second title!"
        print("ObjectB title changed.")
        
        print("objectA: ", objectA.title)
        print("objectB: ", objectB.title)
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting title!")
            await print("objecvtA: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB.")
            let objectB = objectA
            await print("objecvtB: ", objectA.title)
            
            await objectB.updateTitle(newTitle: "Second title!")
            print("ObjectB title changed.")
            
            await print("objectA: ", objectA.title)
            await print("objectB: ", objectB.title)
        }
    }

}

struct MyStruct {
    var title: String
}

// Immutable struct
struct CustomStruct {
    let title: String
    
    func updateTitle(neweTitle: String) -> CustomStruct {
        CustomStruct(title: neweTitle)
    }
}

struct MutatingStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        self.title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("Struct3: ", struct3.title)
        struct3 = struct3.updateTitle(neweTitle: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)

    }
    
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        self.title = newTitle
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        self.title = newTitle
    }
}

extension StructClassActorBootcamp {
    
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("class1: ", class1.title)
        class1.title = "Title2"
        print("class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("class22 ", class2.title)
        class2.title = "Title2"
        print("class22 ", class2.title)
    }
    
}
