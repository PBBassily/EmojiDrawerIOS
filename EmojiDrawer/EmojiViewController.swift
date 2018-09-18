//
//  EmojiViewController.swift
//  EmojiDrawer
//
//  Created by Paula Boules on 9/17/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit

class EmojiViewController: UIViewController, UIDropInteractionDelegate,UIScrollViewDelegate {
    
    var artView =  EmojiView()
    
    @IBOutlet weak var dropZone: UIView! {didSet{
        dropZone.addInteraction(UIDropInteraction.init(delegate: self))
        }
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(artView)
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return artView
    }
    
    var emjiArtBackgroundImage: UIImage? {
        get {
            return artView.backgroundImage
        }
        set {
            scrollView?.zoomScale = 1
            artView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            artView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            if let dropzone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView?.zoomScale = max(dropzone.bounds.width/size.width, dropzone.bounds.height/size.height)
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    var imageFetcher : ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        imageFetcher = ImageFetcher() { (url , image) in
            DispatchQueue.main.async {
                self.emjiArtBackgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self, completion: { nsurls in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        })
        
        session.loadObjects(ofClass: UIImage.self, completion: { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        })
    }
  
    
}
