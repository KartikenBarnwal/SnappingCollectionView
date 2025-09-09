//
//  SnappingFlowLayout.swift
//  SnappingCollectionView
//
//  Created by Kartiken Barnwal on 09/09/25.
//

import UIKit

protocol SnappingFlowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, didSnapTo indexPath: IndexPath)
}

final class SnappingFlowLayout: UICollectionViewFlowLayout {
    
    /// How far around the proposed area we look for candidate cells.
    /// Bigger means more robust for fast flicks with large momentum.
    public var searchMultiplier: CGFloat = 1.5
    
    /// The velocity threshold above which we consider snapping to the next or previous item.
    /// Lower → easier to trigger a “flick” (even on gentle swipes).
    /// Higher → only really fast swipes are treated as flicks.
    public var velocityThreshold: CGFloat = 0.2
    
    /// Multiplier to determine the maximum drag distance allowed to trigger snapping to next/previous item.
    /// Larger → even relatively bigger drags still count as “tiny,” so more swipes get promoted to force next/previous.
    /// Smaller → only really short drags are considered “tiny,” reducing sensitivity.
    public var distanceThresholdMultiplier: CGFloat = 0.75
    
    weak var snappingDelegate: SnappingFlowLayoutDelegate?
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        guard scrollDirection == .horizontal else { return proposedContentOffset }
        
        let bounds = collectionView.bounds
        let halfWidth = bounds.width / 2
        
        // The horizontal center is we accepted the 'proposedContentOffset'
        let proposedCenterX = proposedContentOffset.x + halfWidth
        
        // Look for layout attributes near the proposed rect
        // We exapand the rect to be safer for fast flicks
        var searchRect = CGRect(origin: .zero, size: bounds.size)
        searchRect.origin.x = proposedContentOffset.x - bounds.width * (searchMultiplier - 1) / 2
        searchRect.size.width = bounds.width * searchMultiplier
        
        guard let attributes = layoutAttributesForElements(in: searchRect), !attributes.isEmpty else {
            return proposedContentOffset
        }
        
        // Pick the item whose center is closest to the proposed visible center
        let closest = attributes
            .filter { $0.representedElementCategory == .cell }
            .min(by: { lhs, rhs in
                abs(lhs.center.x - proposedCenterX) < abs(rhs.center.x - proposedCenterX)
            })
        guard closest != nil else { return proposedContentOffset }
        
        let currentOffsetX = collectionView.contentOffset.x
        let dragDistance = proposedContentOffset.x - currentOffsetX
        
        let cellAttributes = attributes.filter { $0.representedElementCategory == .cell }
        let currentCenterX = currentOffsetX + halfWidth
        
        guard let currentAttr = cellAttributes.min(by: { abs($0.center.x - currentCenterX) < abs($1.center.x - currentCenterX) }) else {
            return proposedContentOffset
        }
        
        guard let proposedAttr = cellAttributes.min(by: { abs($0.center.x - proposedCenterX) < abs($1.center.x - proposedCenterX) }) else {
            return proposedContentOffset
        }
        
        var targetAttr = proposedAttr
        
        if abs(velocity.x) > velocityThreshold,
           abs(dragDistance) < (proposedAttr.bounds.width + minimumLineSpacing) * distanceThresholdMultiplier {
            
            if let currentIndex = cellAttributes.firstIndex(of: currentAttr) {
                var targetIndex = currentIndex
                if velocity.x > 0 {
                    targetIndex = min(currentIndex + 1, cellAttributes.count - 1)
                } else if velocity.x < 0 {
                    targetIndex = max(currentIndex - 1, 0)
                }
                targetAttr = cellAttributes[targetIndex]
            }
        }
        
        snappingDelegate?.collectionView(collectionView, didSnapTo: targetAttr.indexPath)
        
        // Offset that would center that item
        var targetX = targetAttr.center.x - halfWidth
        
        // Clamp to content bounds so first/last have natural resting positions.
        let inset = collectionView.adjustedContentInset
        let minX = -inset.left
        let maxX = collectionView.contentSize.width - bounds.width + inset.right
        targetX = max(minX, min(targetX, maxX))
        
        return CGPoint(x: targetX, y: proposedContentOffset.y)
    }
}

