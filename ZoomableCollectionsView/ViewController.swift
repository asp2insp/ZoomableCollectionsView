//
//  ViewController.swift
//  ZoomableCollectionsView
//
//  Created by Josiah Gaskin on 6/1/15.
//  Copyright (c) 2015 asp2insp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    let flowLayout = UICollectionViewFlowLayout()
    var baseSize : CGSize!
    var maxSize : CGSize!
    let minSize = CGSizeMake(30.0, 30.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        maxSize = view.bounds.size
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
        cell.checkbox.backgroundColor = cell.selected ? UIColor.redColor() : UIColor.whiteColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectableImageCell
        cell.checkbox.backgroundColor = UIColor.redColor()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectableImageCell {
            cell.checkbox.backgroundColor = UIColor.whiteColor()
        }
    }

    @IBAction func didPinch(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began:
            baseSize = flowLayout.itemSize
        case .Ended, .Cancelled, .Changed:
            flowLayout.itemSize = aspectScaleWithConstraints(baseSize, scale: sender.scale, max: maxSize, min: minSize)
        default:
            return
        }
    }
    
    func aspectScaleWithConstraints(size: CGSize, scale: CGFloat, max: CGSize, min: CGSize) -> CGSize {
        let maxHScale = fmax(max.width / size.width, 1.0)
        let maxVScale = fmax(max.height / size.height, 1.0)
        let scaleBoundedByMax = fmin(fmin(scale, maxHScale), maxVScale)
        let minHScale = fmin(min.width / size.width, 1.0)
        let minVScale = fmin(min.height / size.height, 1.0)
        let scaleBoundedByMin = fmax(fmax(scaleBoundedByMax, minHScale), minVScale)
        return CGSizeMake(size.width * scaleBoundedByMin, size.height * scaleBoundedByMin)
    }
}

class SelectableImageCell : UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var checkbox: UICheckbox!
    
}