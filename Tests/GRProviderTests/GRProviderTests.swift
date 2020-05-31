//
//  GRProviderTests.swift
//  GRProviderTests
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import XCTest
@testable import GRProvider
@testable import DeepDiff

class GRProviderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBindingToSimpleProviderWithOneSection() throws {
        let tableView = UITableView()
        let provider = GRSimpleTableViewProvider<String>()
        
        let items = (1...10).map { "Item \($0)" }
        provider.bind(to: tableView, items: items)
        
        XCTAssert(tableView.numberOfSections == 1)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 10)
    }

    func testBindingToTableProviderWithOneSection() throws {
        
        struct Section: Sectionable {
            
            var items: [Item]
            
            struct Item {
                let value: String
            }
        }
        
        let tableView = UITableView()
        let provider = GRTableViewProvider<Section>()
        
        let sections = (1...3).map { _ in Section(items: (1...10).map { Section.Item(value: "\($0)") }) }
        provider.bind(to: tableView, sections: sections)
        
        XCTAssert(tableView.numberOfSections == 3)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 10)
    }
    
    struct DeepDiffSection: Sectionable, DiffAware, Equatable {
        
        var diffId: Int { self.id }
        
        static func compareContent(_ a: DeepDiffSection, _ b: DeepDiffSection) -> Bool {
            a.diffId == b.diffId
        }
        
        let id: Int
        let items: [Item]
        
        struct Item: DiffAware, Equatable {
            var diffId: String { self.value }
            
            static func compareContent(_ a: DeepDiffSection.Item, _ b: DeepDiffSection.Item) -> Bool {
                a.diffId == b.diffId
            }
            
            let value: String
            
        }
    }
    
    func testDeepDiffDiferencesInSectionsWhereOneSectionMissing() throws {
                
        let oldSections = [DeepDiffSection(id: 1, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")]), DeepDiffSection(id: 2, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")])]
        
        let newSections = [DeepDiffSection(id: 1, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")])]
                
        let (sectionChanges, itemsChanges, sectionIndexes) = DeepDiffHelper.intersect(oldSections: oldSections, newSections: newSections)
        
        XCTAssert(sectionChanges.count == 1)
        XCTAssert(itemsChanges[1].count == 3 && itemsChanges[0].count == 0)
        XCTAssert(sectionIndexes.count == 2)
        XCTAssert(sectionChanges[0].delete?.item == DeepDiffSection(id: 2, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")]))
        
    }
    
    func testDeepDiffDiferencesItemSwitchedInSectionTwo() throws {                
        let oldSections = [DeepDiffSection(id: 1, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")]), DeepDiffSection(id: 2, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")])]
        
        let newSections = [DeepDiffSection(id: 1, items: [.init(value: "1"), .init(value: "2"), .init(value: "3")]), DeepDiffSection(id: 2, items: [.init(value: "1"), .init(value: "3"), .init(value: "2"), .init(value: "4")])]
                
        let (sectionChanges, itemsChanges, sectionIndexes) = DeepDiffHelper.intersect(oldSections: oldSections, newSections: newSections)
        
        XCTAssert(sectionChanges.count == 0)
        XCTAssert(itemsChanges[1].count == 3 && itemsChanges[0].count == 0)
        XCTAssert(sectionIndexes.count == 2)
        XCTAssert(itemsChanges[1][0].move?.item == .init(value: "3"))
        XCTAssert(itemsChanges[1][0].move?.toIndex == 1)
        XCTAssert(itemsChanges[1][0].move?.fromIndex == 2)
        XCTAssert(itemsChanges[1][1].move?.item == .init(value: "2"))
        XCTAssert(itemsChanges[1][1].move?.toIndex == 2)
        XCTAssert(itemsChanges[1][1].move?.fromIndex == 1)
        XCTAssert(itemsChanges[1][2].insert?.item == .init(value: "4"))
    }

}
