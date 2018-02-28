//
//  Reorder+CHTCollectionLayout.swift
//  Emogo
//
//  Created by Pushpendra on 13/12/18.
//  Copyright © 2018 Vikas Goyal. All rights reserved.
//

import Foundation
extension CHTCollectionViewWaterfallLayout {
    
    
   
    @objc func handleLongPress(_ longPress: UILongPressGestureRecognizer) {
        let location = longPress.location(in: collectionView!)
        switch longPress.state {
        case .began: startDragAtLocation(location: location)
        case .changed: updateDragAtLocation(location: location)
        case .ended: endDragAtLocation(location: location)
        default:
            break
        }
    }
    
    
    func applyDraggingAttributes(attributes: UICollectionViewLayoutAttributes) {
        attributes.alpha = 0
    }
    /*
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach { a in
            if a.indexPath == draggingIndexPath {
                if a.representedElementCategory == .cell {
                    self.applyDraggingAttributes(attributes: a)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        if let attributes = attributes, indexPath == draggingIndexPath {
            if attributes.representedElementCategory == .cell {
                applyDraggingAttributes(attributes: attributes)
            }
        }
        return attributes
    }
    
    */
  
    
    func startDragAtLocation(location: CGPoint) {
        guard let cv = collectionView else { return }
        guard let indexPath = cv.indexPathForItem(at: location) else { return }
        guard cv.dataSource?.collectionView!(cv, canMoveItemAt: indexPath) == true else { return }
        
        guard let cell = cv.cellForItem(at: indexPath) else { return }

        originalIndexPath = indexPath
        draggingIndexPath = indexPath
        draggingView = cell.snapshotView(afterScreenUpdates: true)
        draggingView!.frame = cell.frame
        cv.addSubview(draggingView!)
        
        
        dragOffset = CGPoint(x: draggingView!.center.x - location.x, y: draggingView!.center.y - location.y)
        
        draggingView?.layer.shadowPath = UIBezierPath(rect: draggingView!.bounds).cgPath
        
        draggingView?.layer.shadowColor = UIColor.black.cgColor
        draggingView?.layer.shadowOpacity = 0.8
        draggingView?.layer.shadowRadius = 10
        
        invalidateLayout()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.draggingView?.alpha = 0.95
            self.draggingView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
    }
    
    func updateDragAtLocation(location: CGPoint) {
        guard let view = draggingView else { return }
        guard let cv = collectionView else { return }
        
        
        view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
        

        if let newIndexPath = cv.indexPathForItem(at: location) {
            if newIndexPath.row == 0 {
                return
            }
            print("current--\(location.y)")
            print("collection---\(cv.contentSize.height)")
            if location.y < cv.contentSize.height {
                print("up")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                   self.offset += 1
                    let index = IndexPath(row: newIndexPath.row + self.offset, section: newIndexPath.section)
                   self.collectionView?.scrollToItemIfAvailable(at: index, at: .top, animated: true)
                }
              
            }else {
                print("down")
                offset += 1
                let index = IndexPath(row: newIndexPath.row - offset, section: newIndexPath.section)
                
                collectionView?.scrollToItemIfAvailable(at: index, at: .bottom, animated: true)
             
            }
            
           cv.moveItem(at: draggingIndexPath!, to: newIndexPath)
            
            draggingIndexPath = newIndexPath
            /*

            if (collectionView?.panGestureRecognizer.translation(in: collectionView).y)! < CGFloat(0.0) {
                print("down")
                let index = IndexPath(row: newIndexPath.row - 1, section: 0)
                if  (collectionView?.hasRowAtIndexPath(indexPath: index))! {
                    collectionView?.scrollToItem(at: index, at: .bottom, animated: true)
                }
            } else {
                print("up")
                let index = IndexPath(row: newIndexPath.row + 1, section: 0)
                if  (collectionView?.hasRowAtIndexPath(indexPath: index))! {
                    collectionView?.scrollToItem(at: index, at: .top, animated: true)
                }
            }
           */
        }
    }
    
   
    
    func endDragAtLocation(location: CGPoint) {
        guard let dragView = draggingView else { return }
        guard let indexPath = draggingIndexPath else { return }
        guard let cv = collectionView else { return }
        guard let datasource = cv.dataSource else { return }
        
        let targetCenter = datasource.collectionView(cv, cellForItemAt: indexPath).center
        offset = 0
        let shadowFade = CABasicAnimation(keyPath: "shadowOpacity")
        shadowFade.fromValue = 0.8
        shadowFade.toValue = 0
        shadowFade.duration = 0.4
        dragView.layer.add(shadowFade, forKey: "shadowFade")
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            dragView.center = targetCenter
            dragView.transform = .identity
            
        }) { (completed) in
            
            if indexPath != self.originalIndexPath{
                datasource.collectionView!(cv, moveItemAt: self.originalIndexPath!, to: indexPath)
            }
            
            dragView.removeFromSuperview()
            self.draggingIndexPath = nil
            self.draggingView = nil
            self.invalidateLayout()
        }
        
    }
}

extension UICollectionView {
    func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
        guard dataSource != nil,
            indexPath.section < numberOfSections,
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
                return false
        }
        
        return true
    }
    
    func scrollToItemIfAvailable(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) {
        guard isIndexPathAvailable(indexPath) else { return }
    
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func scrollToItemOrThrow(at indexPath: IndexPath, at scrollPosition: UICollectionViewScrollPosition, animated: Bool) throws {
        guard isIndexPathAvailable(indexPath) else {
            throw Error.invalidIndexPath(indexPath: indexPath, lastIndexPath: lastIndexPath)
        }
        
        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    var lastIndexPath: IndexPath {
        let lastSection = numberOfSections - 1
        return IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                         section: lastSection)
    }
}

extension UICollectionView {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidIndexPath(indexPath: IndexPath, lastIndexPath: IndexPath)
        
        var description: String {
            switch self {
            case let .invalidIndexPath(indexPath, lastIndexPath):
                return "IndexPath \(indexPath) is not available. The last available IndexPath is \(lastIndexPath)"
            }
        }
    }
}
