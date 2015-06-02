//
//  ViewController.swift
//  ZoomableCollectionsView
//
//  Created by Josiah Gaskin on 6/1/15.
//  Copyright (c) 2015 asp2insp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    let flowLayout = UICollectionViewFlowLayout()
    var baseSize : CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imagecell", forIndexPath: indexPath) as! SelectableImageCell
        
        let nameIndex = indexPath.row % 13 + 1
        cell.image.image = UIImage(named: "\(nameIndex)")
        return cell
    }

    @IBAction func didPinch(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began:
            baseSize = flowLayout.itemSize
        case .Ended, .Cancelled, .Changed:
            flowLayout.itemSize = CGSizeMake(baseSize.width * sender.scale, baseSize.height * sender.scale)
        default:
            return
        }
    }
}

class SelectableImageCell : UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}