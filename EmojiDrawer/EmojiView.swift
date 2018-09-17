//
//  EmojiView.swift
//  EmojiDrawer
//
//  Created by Paula Boules on 9/17/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit

class EmojiView: UIView {

    var backgroundImage  : UIImage? {didSet {setNeedsDisplay()}}
    
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }


}
