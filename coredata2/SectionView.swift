//
//  SectionView.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/17/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct SectionView: View {
    var list: ListEntity4

    var request : NSFetchRequest<SectionEntity4> =  SectionEntity4.fetchRequest()
    @State var sections: [SectionEntity4] = []
    
    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    @State private var isShowingAlert = false
    @State private var alertInput = ""
    @State private var trigger: Bool = false

    init(_ list: ListEntity4) {
        self.list = list
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SectionEntity4.objectID, ascending: true)]
        request.predicate = NSPredicate(format: "list.id == %@", list.id! as CVarArg)

        let sections = try! context.fetch(request)
        self._sections = State(initialValue: sections)
    }
    
    func buildItem(_ section:SectionEntity4) -> some View {
        let view = LazyView(CardView(self.list, section))
        
        return NavigationLink(destination: view) {
            VStack(alignment: .leading) {
                Text((section as SectionEntity4).name!).font(.headline)
                Text(String((section as SectionEntity4).wordCount)).font(.subheadline)
            }
            
        }
    }
    
    func reload() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        self.sections = try! context.fetch(self.request)
        self.trigger.toggle()
    }
    
    var body: some View {
        print("build \(trigger)")

        let context = CoreDataStack.shared.persistentContainer.viewContext

        let content = List {
            ForEach(sections, id: \.id) { section in
                self.buildItem(section)

            }.onDelete { offsets in
                for index in offsets {
                    self.list.wordCount -= self.sections[index].wordCount
                    context.delete(self.sections[index])
                }
                try! context.save()
            }
            
        }.onReceive(self.didSave) { _ in
            self.reload()
            
        }.onAppear(perform: {
            self.reload()
            
        })
        .navigationBarTitle(list.name ?? "")
        
        #if os(iOS)
        return content.navigationBarItems(trailing:
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
            .textFieldAlert(isShowing: $isShowingAlert,
                            text: $alertInput,
                            title: "Add Section") {
                                DispatchQueue.main.async {
                                    let section = SectionEntity4(context: context)
                                    section.id = UUID()
                                    section.list = self.list
                                    section.name = self.alertInput
                                    section.wordCount = 0
                                    
                                    try! context.save()
                                }
                                
        }
        
        #else
        return content

        #endif
        
        
    }
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView(ListEntity4())
    }
}
