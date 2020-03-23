//
//  AddCard.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/18/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct LabelTextField : View {
    var label: String
    
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.headline)
            
            TextField("", text: self.$text)
                .padding(.all)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5.0)
            }
            .padding(10)
        
    }
}

struct TextField_UI : UIViewRepresentable {
    typealias UIViewType = UITextView
    
    @Binding var text: String
    var onEditingChanged: ((String) -> Void)?
    var onCommit: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = nil
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = .zero
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var field: TextField_UI
        
        init(_ field: TextField_UI) {
            self.field = field
        }
        
        func textViewDidChange(_ textView: UITextView) {
            field.text = textView.text
        }
    }
}

struct AddCard: View {
    @State private var wordInput = ""
    @State private var pinyinInput = ""
    @State private var translationInput = ""
    @State private var selectorIndex = 0
    @State private var csvInput = ""
    
    @Binding var sheetVisible: Bool

    var list: ListEntity4
    var section: SectionEntity4
     
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Picker("", selection: $selectorIndex) {
                        Text("Single").tag(0)
                        Text("Multiple").tag(1)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    (selectorIndex == 0) ?
                    AnyView(VStack(alignment: .leading) {
                        LabelTextField(label: "Word", text: $wordInput)
                        LabelTextField(label: "Pinyin", text: $pinyinInput)
                        LabelTextField(label: "Translation", text: $translationInput)
                    }.listRowInsets(EdgeInsets()))
                    
                        : AnyView(VStack {
                            Text("Enter list of words in CSV format, e.g.:\n\"一\", \"yī\", \"one\"\n\"二\", \"èr\", \"two\"\n...")
                            Spacer()
                            TextField_UI(text: $csvInput).border(Color.gray, width: 1)
                                .frame(height: 300.0)
                            
                        })
                }
                
            }
            .onAppear { UITableView.appearance().separatorStyle = .none }
            .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
            .navigationBarTitle(Text("New Card"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.sheetVisible = false
                
                let context = CoreDataStack.shared.persistentContainer.viewContext

                if self.selectorIndex == 0 {
                    let card = CardEntity(context: context)
                    card.id = UUID()
                    card.list = self.list
                    card.section = self.section
                    
                    card.word = self.wordInput
                    card.pinyin = self.pinyinInput
                    card.translation = self.translationInput
                    
                    self.list.wordCount += 1
                    self.section.wordCount += 1
                    
                    try! context.save()
                    
                } else {
                    let cards: [VocabCard] = VocabDeck.loadCSV(self.csvInput)
                    
                    for c in cards {
                        let card = CardEntity(context: context)
                        card.id = UUID()
                        card.list = self.list
                        card.section = self.section
                        card.word = c.word
                        card.pinyin = c.pinyin
                        card.translation = c.translation
                        
                        self.list.wordCount += 1
                        self.section.wordCount += 1
                        
                        try! context.save()
                    }
                }
               
            }) {
                Text("Add").bold()
            })
        }
    }
}

struct AddCard_Previews: PreviewProvider {
    static var previews: some View {
        AddCard(sheetVisible: .constant(false), list: ListEntity4(), section: SectionEntity4())
    }
}
