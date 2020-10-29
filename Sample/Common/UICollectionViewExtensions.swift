//
//  UICollectionViewExtensions.swift
//  Example
//
//  Created by Dominik Pethö on 5/27/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /// Register reusable cell with specified class type.
    public func registerCell<T: UICollectionViewCell>(fromClass type: T.Type)  {
        register(UINib(nibName: String(describing: type), bundle: nil), forCellWithReuseIdentifier: String(describing: type))
    }
    
    /// Register reusable supplementary view with specified class type.
    public func register<T: UICollectionReusableView>(viewClass type: T.Type, forSupplementaryViewOfKind: String = UICollectionView.elementKindSectionHeader) {
        register(UINib(nibName: String(describing: type), bundle: nil), forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: String(describing: type))
    }
    
    /// Dequeue reusable supplementary view with specified class type.
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
    /// Dequeue reusable cell with specified class type.
    public func dequeueReusableCell<T: UICollectionViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as! T
    }
    
    /// Deselect first selected item along UIViewController`s transition coordinator.
    public func deselectSelectedItem(along transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        guard let selectedIndexPath = indexPathsForSelectedItems?.first else { return }
        
        guard let coordinator = transitionCoordinator else {
            deselectItem(at: selectedIndexPath, animated: false)
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.deselectItem(at: selectedIndexPath, animated: true)
        }) { [weak self] (context) in
            if context.isCancelled {
                self?.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
            }
        }
    }
    
}
