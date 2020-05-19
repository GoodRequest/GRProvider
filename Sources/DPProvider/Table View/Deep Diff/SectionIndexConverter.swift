//
//  SectionIndexConverter.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/27/20.
//

import Foundation
import DeepDiff

struct ChangeWithIndex {
  
  let inserts: [Int]
  let deletes: [Int]
  let replaces: [Int]
  let moves: [(from: Int, to: Int)]

  init(
    inserts: [Int],
    deletes: [Int],
    replaces:[Int],
    moves: [(from: Int, to: Int)]) {

    self.inserts = inserts
    self.deletes = deletes
    self.replaces = replaces
    self.moves = moves
  }
    
}

class SectionIndexConverter {
  
  init() {}
  
  func convert<S>(changes: [Change<S>]) -> ChangeWithIndex {
    let inserts = changes.compactMap({ $0.insert }).map({ $0.index })
    let deletes = changes.compactMap({ $0.delete }).map({ $0.index })
    let replaces = changes.compactMap({ $0.replace }).map({ $0.index })
    let moves = changes.compactMap({ $0.move }).map({
      (
        from: $0.fromIndex,
        to: $0.toIndex
      )
    })
    
    return ChangeWithIndex(
      inserts: inserts,
      deletes: deletes,
      replaces: replaces,
      moves: moves
    )
  }
    
}
