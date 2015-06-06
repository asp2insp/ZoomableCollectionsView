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
    
    // Long press handling
    var selectionStart : NSIndexPath!
    var previousRange : [NSIndexPath]?
    
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
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SelectableImageCell {
            cell.checkbox.checkState = M13CheckboxStateChecked
        }
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
    
    func aspectScaleWithConstraints(size: CGSize, scale: CGFloat, max: CGSize, min: CGSize) -> CGSize {
        let maxHScale = fmax(max.width / size.width, 1.0)
        let maxVScale = fmax(max.height / size.height, 1.0)
        let scaleBoundedByMax = fmin(fmin(scale, maxHScale), maxVScale)
        let minHScale = fmin(min.width / size.width, 1.0)
        let minVScale = fmin(min.height / size.height, 1.0)
        let scaleBoundedByMin = fmax(fmax(scaleBoundedByMax, minHScale), minVScale)
        return CGSizeMake(size.width * scaleBoundedByMin, size.height * scaleBoundedByMin)
    }
    
    
    @IBAction func didLongPressAndDrag(sender: UILongPressGestureRecognizer) {
        let touchCoords = sender.locationInView(collectionView)
        switch sender.state {
        case .Began, .Changed:
            let currentIndex = pointToIndexPath(touchCoords)
            if currentIndex != nil {
                if selectionStart == nil {
                    selectionStart = currentIndex
                    selectItemAtIndexPathIfNecessary(selectionStart)
                    return
                }
                let itemsToSelect = getIndexRange(start: selectionStart, end: currentIndex!)
                let itemsToDeselect = difference(previousRange, minus: itemsToSelect)
                for path in itemsToDeselect {
                    collectionView.deselectItemAtIndexPath(path, animated: true)
                    self.collectionView(collectionView, didDeselectItemAtIndexPath: path)
                }
                for path in itemsToSelect {
                    selectItemAtIndexPathIfNecessary(path)
                }
                previousRange = itemsToSelect
            }
        case .Cancelled, .Ended:
            selectionStart = nil
            previousRange = nil
        default:
            return
        }
    }
    
    func selectItemAtIndexPathIfNecessary(path: NSIndexPath) {
        if !(collectionView.cellForItemAtIndexPath(path)?.selected ?? false) {
            collectionView.selectItemAtIndexPath(path, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            self.collectionView(collectionView, didSelectItemAtIndexPath: path)
        }
    }
    
    // Return the difference of the given arrays of index paths
    func difference(a: [NSIndexPath]?, minus b: [NSIndexPath]?) -> [NSIndexPath] {
        if a == nil {
            return []
        }
        if b == nil {
            return a!
        }
        var final = a!
        for item in b! {
            if let index = find(final, item) {
                final.removeAtIndex(index)
            }
        }
        return final
    }
    
    // Return an array of NSIndexPaths between the given start and end, inclusive
    func getIndexRange(#start: NSIndexPath, end: NSIndexPath) -> [NSIndexPath] {
        var range : [NSIndexPath] = []
        let numItems = abs(start.row - end.row)
        let section = start.section
        for var i = 0; i <= numItems; i++ {
            let newRow = start.row < end.row ? start.row+i : start.row-i
            if newRow >= 0 && newRow < collectionView.numberOfItemsInSection(section) {
                range.append(NSIndexPath(forRow: newRow, inSection: section))
            }
        }
        return range
    }
    
    // Convert a touch point to an index path of the cell under the point.
    // Returns nil if no cell exists under the given point.
    func pointToIndexPath(point: CGPoint) -> NSIndexPath? {
        let fingerRect = CGRectMake(point.x-5, point.y-5, 10, 10)
        for item in collectionView.visibleCells() {
            let cell = item as! SelectableImageCell
            if CGRectIntersectsRect(fingerRect, cell.frame) {
                return collectionView.indexPathForCell(cell)
            }
        }
        return nil
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