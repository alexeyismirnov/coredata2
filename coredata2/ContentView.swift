//
//  ContentView.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/8/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    
    var request : NSFetchRequest<ListEntity4> =  ListEntity4.fetchRequest()
    @State var lists: [ListEntity4] = []
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)

    @State private var isShowingAlert = false
    @State private var alertInput = ""
    
    @State private var trigger: Bool = false
    
    init() {
        let context = CoreDataStack.shared.persistentContainer.viewContext

        request.sortDescriptors = [NSSortDescriptor(keyPath: \ListEntity4.objectID, ascending: true)]
        
        let lists = try! context.fetch(request)
        self._lists = State(initialValue: lists)
    }
   
    func buildItem(_ list:ListEntity4) -> some View {
        let view = LazyView(SectionView(list))

        return NavigationLink(destination: view) {
            VStack {
                Text((list as ListEntity4).name!).font(.headline)
                Text(String((list as ListEntity4).wordCount)).font(.subheadline)
            }
           
        }
    }
    
    func reload() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        self.lists = try! context.fetch(self.request)
        self.trigger.toggle()
    }
    
    var body: some View {
        print("build \(trigger)")
        
        let content = List {
            ForEach(lists, id: \.id)  { list in
                self.buildItem(list)
                
            }.onDelete { offsets in
                for index in offsets {
                    self.context.delete(self.lists[index])
                }
                try! self.context.save()
            }
            
        }.onReceive(self.didSave) { _ in
            self.reload()
            
        }.onAppear(perform: {
            self.reload()
        })
        
        #if os(iOS)
        return NavigationView { content
            .navigationBarTitle("Flashcards", displayMode: .inline)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.alertInput = ""
                        withAnimation {
                            self.isShowingAlert.toggle()
                        }
                    },
                           label: {
                            Text("Add")
                    })
                    
                }
            )
        }.textFieldAlert(isShowing: $isShowingAlert,
                         text: $alertInput,
                         title: "Add List") {
                            
                            DispatchQueue.main.async {
                                let list1 = ListEntity4(context: self.context)
                                list1.id = UUID()
                                list1.name = self.alertInput
                                list1.wordCount = 0
                                
                                try! self.context.save()
                            }
                            
        }
        
        #else
        return content
        #endif

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
