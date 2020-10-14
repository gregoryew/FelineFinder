//
//  HorizontalLayoutVaryingWidths.swift
//  Feline Finder
//
//  Created by Gregory Williams on 10/12/20.
//  Copyright © 2020 Gregory Williams. All rights reserved.
//

import UIKit

protocol HorizontalLayoutVaryingWidthsLayoutDelegate: AnyObject {
    func collectionView(
      _ collectionView: UICollectionView,
      widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class HorizontalLayoutVaryingWidthsAttributes: UICollectionViewLayoutAttributes {
  
  var imageWidth: CGFloat = 0
  
  override func copy(with zone: NSZone?) -> Any {
    let copy = super.copy(with: zone) as! HorizontalLayoutVaryingWidthsAttributes
    copy.imageWidth = imageWidth
    return copy
  }
  
  override func isEqual(_ object: Any?) -> Bool {
    if let attributes = object as? HorizontalLayoutVaryingWidthsAttributes {
      if attributes.imageWidth == imageWidth {
        return super.isEqual(object)
      }
    }
    return false
  }
  
}

class HorizontalLayoutVaryingWidths: UICollectionViewLayout {
  
  var delegate: HorizontalLayoutVaryingWidthsLayoutDelegate!
  var numberOfRows = 1
  var cellPadding: CGFloat = 0
  var columnHeight: CGFloat = 100
  
  var cache = [HorizontalLayoutVaryingWidthsAttributes]()
  fileprivate var contentWidth: CGFloat = 0
  fileprivate var height: CGFloat {
    get {
      let insets = collectionView!.contentInset
        return collectionView!.bounds.height - (insets.top + insets.bottom)
    }
  }
  
  override var collectionViewContentSize : CGSize {
    return CGSize(width: contentWidth, height: height)
  }
  
  override class var layoutAttributesClass : AnyClass {
    return HorizontalLayoutVaryingWidthsAttributes.self
  }
  
  override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  override func prepare() {
    cache.removeAll()
    if cache.isEmpty {
      var yOffsets = [CGFloat]()
      for row in 0..<numberOfRows {
        yOffsets.append(CGFloat(row) * columnHeight)
      }
      
      var xOffsets = [CGFloat](repeating: 0, count: numberOfRows)
      
      let row = 0
      for item in 0..<collectionView!.numberOfItems(inSection: 0) {
        let indexPath = IndexPath(item: item, section: 0)
        
        let width = delegate.collectionView(collectionView!, widthForPhotoAtIndexPath: indexPath)

        let frame = CGRect(x: xOffsets[row], y: yOffsets[row], width: width, height: columnHeight)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        let attributes = HorizontalLayoutVaryingWidthsAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        attributes.imageWidth = width
        cache.append(attributes)
        contentWidth = max(contentWidth, frame.maxX)
        xOffsets[row] = xOffsets[row] + width
      }
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
}
