//
//  HostingController.swift
//  iwatch Extension
//
//  Created by Alexey Smirnov on 3/8/20.
//  Copyright © 2020 Alexey Smirnov. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    
    override var body: AnyView {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true

        return AnyView(ContentView().environment(\.managedObjectContext, context))
    }
}
