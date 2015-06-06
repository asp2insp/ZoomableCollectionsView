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
        cell.nameIndex = nameIndex
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectableImageCell
        cell.checkbox.checkState = M13CheckboxStateChecked
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectableImageCell {
            cell.checkbox.checkState = M13CheckboxStateUnchecked
        }
    }

    @IBAction func didPinch(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began:
            baseSize = flowLayout.itemSize
        case .Changed:
            flowLayout.itemSize = aspectScaleWithConstraints(baseSize, scale: sender.scale, max: maxSize, min: minSize)
        case .Ended, .Cancelled:
            flowLayout.itemSize = aspectScaleWithConstraints(baseSize, scale: sender.scale, max: maxSize, min: minSize)
        default:
            return
        }
    }
    
//    func aspectScaleToEvenDivisor(baseSize: CGSize, candidateScale: CGFloat, viewport: CGSize) -> CGSize {
//        // Constrain to min of viewport
//        let constraintName = viewport.width < viewport.height ? "width" : "height"
//        
//        var finalScale = candidateScale
//        let sizeWithPadding = CGSizeMake(baseSize.width + flowLayout.minimumInteritemSpacing, baseSize.height * flowLayout.minimumLineSpacing)
//        
//        var candidateSize = CGSizeMake(sizeWithPadding.width * candidateScale, sizeWithPadding.height * candidateScale)
//        if constraintName == "width" {
//            let numberOfCols = round(viewport.width / candidateSize.width)
//            finalScale = (viewport.width / numberOfCols) / sizeWithPadding.width
//        } else {
//            let numberOfRows = round(viewport.height / candidateSize.height)
//            finalScale = (viewport.height / numberOfRows) / sizeWithPadding.height
//        }
//        return CGSizeMake(baseSize.width * finalScale, baseSize.height * finalScale)
//    }
    
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
    @IBOutlet weak var checkbox: M13Checkbox!
    
    var nameIndex : Int = 0 {
        didSet {
            image.image = UIImage(named: "\(nameIndex)")
            checkbox.checkState = selected ? M13CheckboxStateChecked : M13CheckboxStateUnchecked
            checkbox.radius = 0.5 * checkbox.frame.size.width;
            checkbox.flat = true
            checkbox.tintColor = checkbox.strokeColor
            checkbox.checkColor = UIColor.whiteColor()
        }
    }
}