//
//  EmojiView.swift
//  EmojiDrawer
//
//  Created by Paula Boules on 9/17/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit

class EmojiView: UIView, UIDropInteractionDelegate {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder )
        setup()
    }
    
    
    private func setup() {
        addInteraction(UIDropInteraction(delegate: self))
    }
    var backgroundImage  : UIImage? {didSet {setNeedsDisplay()}}
    
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { (providers) in
            for attributedString in providers as? [NSAttributedString] ?? [] {
                self.addLabel(attributedString: attributedString, centeredAt: session.location(in: self))
            }
        }
    }
    
    private func addLabel(attributedString : NSAttributedString , centeredAt point : CGPoint) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        self.addSubview(label)
    }
    
}

