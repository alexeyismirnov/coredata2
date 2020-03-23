//
//  CardView.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI
import CoreData

struct CardView: View {
    var list: ListEntity4
    var section: SectionEntity4
    
    var request : NSFetchRequest<CardEntity> =  CardEntity.fetchRequest()
    @State var cards: [CardEntity] = []
    @State private var sheetVisible = false

    private var didSave =  NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    init(_ list: ListEntity4, _ section: SectionEntity4) {
        self.list = list
        self.section = section
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.objectID, ascending: true)]
        request.predicate = NSPredicate(format: "list.id == %@ && section.id == %@", list.id! as CVarArg, section.id! as CVarArg)
        
        let cards = try! context.fetch(request)
        self._cards = State(initialValue: cards)
    }
    
    var body: some View {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        let content = List {
            ForEach(cards, id: \.id) { card in
                VStack(alignment: .leading) {
                    Text((card as CardEntity).word!).font(.headline)
                    Text((card as CardEntity).pinyin!).font(.subheadline)
                }
                
            }.onDelete { offsets in
                for index in offsets {
                    self.list.wordCount -= 1
                    self.section.wordCount -= 1
                    context.delete(self.cards[index])
                }
                try! context.save()
            }
            
        }.onReceive(self.didSave) { _ in
            self.cards = try! context.fetch(self.request)
        }.navigationBarTitle(section.name ?? "")
        
        #if os(iOS)
        return content.navigationBarItems(trailing:
            HStack {
                Button(action: {
                    withAnimation {
                        self.sheetVisible.toggle()
                    }
                },
                       label: {
                        Text("Add")
                })
            }
        ).sheet(isPresented: $sheetVisible) {
            AddCard(sheetVisible: self.$sheetVisible, list: self.list, section: self.section)
        }
        
        #else
        return content
        #endif
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(ListEntity4(), SectionEntity4())
    }
}
