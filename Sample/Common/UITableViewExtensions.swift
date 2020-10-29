//
//  UITableViewExtensions.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Register reusable cell with specified class type.
    public func registerCell<T: UITableViewCell>(fromClass type: T.Type)  {
        register(UINib(nibName: String(describing: type), bundle: nil), forCellReuseIdentifier: String(describing: type))
    }
    
    /// Register reusable header footer view with specified class type.
    public func registerHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) {
        register(UINib(nibName: String(describing: type), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: type))
    }
    
    /// Dequeue reusable header footer view with specified class type.
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: type)) as? T
    }
    
    /// Dequeue reusable cell with specified class type.
    public func dequeueReusableCell<T: UITableViewCell>(fromClass type: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? T
    }
    
    /// Deselect selected row along UIViewController`s transition coordinator.
    public func deselectSelectedRow(along transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        guard let selectedIndexPath = indexPathForSelectedRow else { return }
        
        guard let coordinator = transitionCoordinator else {
            deselectRow(at: selectedIndexPath, animated: false)
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.deselectRow(at: selectedIndexPath, animated: true)
        }) { [weak self] (context) in
            if context.isCancelled {
                self?.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
}
