//
//  TextFieldAlert.swift
//  coredata2
//
//  Created by Alexey Smirnov on 3/16/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    var action: (() -> Void)?

    var body: some View {
        ZStack {
            self.presenting.disabled(self.isShowing)
            VStack {
                Text(self.title).foregroundColor(.black)
                TextField("", text: self.$text).id(self.isShowing).foregroundColor(.black)
                Divider()
                HStack {
                    Button(action: {
                        withAnimation {
                            self.isShowing.toggle()
                        }
                    }) {
                        Text("Cancel").frame(minWidth: 0, maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        withAnimation {
                            self.isShowing.toggle()
                        }
                        
                        self.action?()

                    }) {
                        Text("OK").frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .frame(width: 250, height: 100)
            .shadow(radius: CGFloat(1))
            .opacity(self.isShowing ? 1.0 : 0.0)
        }
    }

}

extension View {
    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String,
                        action: @escaping () -> Void
                        ) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title,
                       action: action)
    }

}
