//
//  DeepDiffCollectionViewUpdateExtensions.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/27/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit
import DeepDiff

extension UICollectionView {
    
    func insideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
        changesWithIndexPath.deletes.executeIfPresent {
            deleteItems(at: $0)
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            insertItems(at: $0)
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                moveItem(at: move.from, to: move.to)
            }
        }
    }
    
    func outsideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
        changesWithIndexPath.replaces.executeIfPresent {
            self.reloadItems(at: $0)
        }
    }
    
    func insideSectionUpdate(changesWithIndexPath: ChangeWithIndex) {
        
        changesWithIndexPath.deletes.executeIfPresent {
            deleteSections(IndexSet($0))
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            insertSections(IndexSet($0))
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                moveSection(move.from, toSection: move.to)
            }
        }
    }
    
    func outsideSectionUpdate(
        changesWithIndexPath: ChangeWithIndex) {
        
        changesWithIndexPath.replaces.executeIfPresent {
            reloadSections(IndexSet($0))
        }
    }
    
}
