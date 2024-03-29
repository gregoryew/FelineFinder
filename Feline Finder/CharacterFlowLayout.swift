//
//  CharacterFlowLayout.swift
//  Character Collector
/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class CharacterFlowLayout: UICollectionViewFlowLayout {
  
  var standardItemAlpha: CGFloat = 0.5
  var standardItemScale: CGFloat = 0.5
  
  var isSetup = false
  
  override func prepare() {
    super.prepare() 
    if isSetup == false {
      setupCollectionView()
      isSetup = true
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElements(in: rect)
    var attributesCopy = [UICollectionViewLayoutAttributes]()
    
    for itemAttributes in attributes! {
      let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
      changeLayoutAttributes(itemAttributesCopy)
      
      attributesCopy.append(itemAttributesCopy)
    }
    
    return attributesCopy
  }
  
  override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
  
  func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {    
    let collectionCenter = collectionView!.frame.size.height/2
    let offset = collectionView!.contentOffset.y
    let normalizedCenter = attributes.center.y - offset
    
    let maxDistance = self.itemSize.height + self.minimumLineSpacing
    let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
    let ratio = (maxDistance - distance)/maxDistance
    
    let alpha = ratio * (1 - self.standardItemAlpha) + self.standardItemAlpha
    let scale = ratio * (1 - self.standardItemScale) + self.standardItemScale
    attributes.alpha = alpha
    attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
    attributes.zIndex = Int(alpha * 10)
  }
  
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    let layoutAttributes = self.layoutAttributesForElements(in: collectionView!.bounds)
    
    let center = collectionView!.bounds.size.height / 2
    let proposedContentOffsetCenterOrigin = proposedContentOffset.y + center
    
    let closest = layoutAttributes!.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
    
    let targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - center))
    
    return targetContentOffset
  }
  
  func setupCollectionView() {
    self.collectionView!.decelerationRate = UIScrollView.DecelerationRate.fast
   
    let collectionSize = collectionView!.bounds.size
    let yInset = (collectionSize.height - self.itemSize.height) / 2
    let xInset = (collectionSize.width - self.itemSize.width) / 2
    
    self.sectionInset = UIEdgeInsets.init(top: yInset, left: xInset, bottom: yInset, right: xInset)
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
}
