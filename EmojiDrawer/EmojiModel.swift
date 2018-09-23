//
//  EmojiModel.swift
//  EmojiDrawer
//
//  Created by Paula Boules on 9/23/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import Foundation

struct EmojiModel: Codable {
    
    var url : URL
    var emojis = [EmojiInfo]()
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    init(url : URL, emojis: [EmojiInfo] ) {
       self.url = url
        self.emojis = emojis
    }
    
    struct EmojiInfo : Codable {
        let x: Int
        let y: Int
        let size: Int
        let text: String
    }
    
    
}
