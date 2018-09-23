//
//  EmojiViewController.swift
//  EmojiDrawer
//
//  Created by Paula Boules on 9/17/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit


class EmojiViewController: UIViewController, UIDropInteractionDelegate,UIScrollViewDelegate ,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate,
UICollectionViewDropDelegate{
    
    
    // Mark: - Model
    
    var emojiModel : EmojiModel?{
        get {
            if let url = emjiArtBackgroundImage.url {
                let emojis = artView.subviews.compactMap({$0 as? UILabel})
                let emojis2 = emojis.compactMap({EmojiModel.EmojiInfo(label: $0)})
                
                
                return EmojiModel(url: url, emojis: emojis2)
            }else {
                return nil
            }
            
        }
        set {
            emjiArtBackgroundImage = (nil,nil)
            artView.subviews.forEach({$0.removeFromSuperview()})
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url, handler: ({ (url, image) in
                    DispatchQueue.main.async {
                        self.emjiArtBackgroundImage = (url, image)
                        newValue?.emojis.forEach{
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.artView.addLabel(attributedString: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }))
            }
        }
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        
       
        if let json = emojiModel?.json {
           
            if let url = try? FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
                ).appendingPathComponent("Untitled.json"){
                do {
                    try json.write(to: url)
                    print("saved successfuly!")
                } catch let error {
                    print("failed to save \(error)")
                }
            }

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ).appendingPathComponent("Untitled.json"){
            if let jsonData = try? Data.init(contentsOf: url) {
                emojiModel = EmojiModel(jsonData: jsonData)
            }
        }
    }
    
    // Mark: - Storyboard
    
    var artView =  EmojiView()
    
    
    
    @IBOutlet weak var dropZone: UIView! {
        didSet{
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
    
    private var _emojiBackgroundImage: URL?
    
    var emjiArtBackgroundImage: (url: URL?,image: UIImage?) {
        get {
            return (_emojiBackgroundImage, artView.backgroundImage)
        }
        set {
            _emojiBackgroundImage = newValue.url
            scrollView?.zoomScale = 1
            artView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
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
                self.emjiArtBackgroundImage = (url,image)
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
    
    
    
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell {
            let font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
            let text = NSAttributedString(string: EmojisData.data[indexPath.row], attributes: [.font: font])
            emojiCell.emojiHolder.attributedText = text
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // default
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmojisData.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func dragItems(at indexPath :IndexPath ) -> [UIDragItem]{
        if let attributedString  = (collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiHolder.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString // no need for seesions lifeCycle because we are in the same app
            
            return [dragItem]
        }
        return []
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal{
        
        let isInCollectionViewContext = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        
        return UICollectionViewDropProposal(operation: isInCollectionViewContext ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        
        let destinationPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0 )
        
        for item in coordinator.items {
            
            if let sourcePath = item.sourceIndexPath {
                // local drop
                print("local drop")
                if let attributedString = (item.dragItem.localObject as? NSAttributedString) {
                    collectionView.performBatchUpdates({
                        EmojisData.data.remove(at: sourcePath.item)
                        EmojisData.data.insert(attributedString.string, at: destinationPath.item)
                        collectionView.deleteItems(at: [sourcePath])
                        collectionView.insertItems(at: [destinationPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationPath)
                    
                }
                
            }else  {
                
                print("outsource")
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationPath, reuseIdentifier: "DropPlaceholderCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self, completionHandler: { (provider, error) in
                    DispatchQueue.main.async {
                        
                        if let attributedString = provider as? NSAttributedString {
                            print("i can")
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionPath in
                                EmojisData.data.insert(attributedString.string, at: insertionPath.item )
                            })
                        }
                        else  {
                            print("i cannt")
                            placeholderContext.deletePlaceholder()
                        }
                    }
                    
                }
                )
                
            }
            
        }
        
    }
    
}
extension EmojiModel.EmojiInfo {
    init?(label: UILabel){
        if let attributedText = label.attributedText {
            x = Int(label.center.x)
            y = Int(label.center.y)
            size = Int(32)
            text = attributedText.string
            print("success")
        } else {
            return nil
            print("fail")
        }
        
    }
}
