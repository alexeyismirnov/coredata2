//
//  Data.swift
//  lanternhsk
//
//  Created by Alexey Smirnov on 12/15/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SwiftUI

struct VocabCard: Hashable, Codable, Identifiable {
    var id: UUID
    var word: String
    var pinyin: String
    var translation: String
}

struct VocabDeck: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var filename: String
    var wordCount: Int
    
    func load<T: Decodable>() -> T {
        let data: Data
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
        
    }
    
    static func loadCSV(_ dataString: String) -> [VocabCard] {
        var items = [VocabCard]()
        let lines: [String] = dataString.components(separatedBy: NSCharacterSet.newlines) as [String]

        for line in lines {
            var values: [String] = []
            if line != "" {
                if line.range(of: "\"") != nil {
                    var textToScan:String = line
                    var value:String?
                    var textScanner:Scanner = Scanner(string: textToScan)
                    while textScanner.string != "" {
                        if (textScanner.string as NSString).substring(to: 1) == "\"" {
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                            value = textScanner.scanUpToString("\"")
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                        } else {
                            value = textScanner.scanUpToString(",")
                        }

                         values.append(value ?? "")

                         if textScanner.currentIndex < textScanner.string.endIndex {
                            textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                            textToScan = String(textScanner.string[textScanner.currentIndex...])
                         } else {
                             textToScan = ""
                         }
                         textScanner = Scanner(string: textToScan)
                    }

                    // For a line without double quotes, we can simply separate the string
                    // by using the delimiter (e.g. comma)
                } else  {
                    values = line.components(separatedBy: ",")
                }
            }
            
            if values.count > 0 {
                items.append(VocabCard(id: UUID(), word: values[0], pinyin: values[1], translation: values[2]))
            }
        }
        
        return items
    }
}



