# DPProvider
[![iOS Version](https://img.shields.io/badge/iOS_Version->=_11.0-brightgreen?logo=apple&logoColor=green)]() [![Swift Version](https://img.shields.io/badge/Swift_Version-5.2-green?logo=swift)](https://docs.swift.org/swift-book/)
[![Supported devices](https://img.shields.io/badge/Supported_Devices-iPhone/iPad-green)]()
[![Contains Test](https://img.shields.io/badge/Tests-YES-blue)]()
[![Dependency Manager](https://img.shields.io/badge/Dependency_Manager-SPM-red)](#swiftpackagemanager)

## Table of content

*  [Why to use?](#why-to-use)
*  [How to use?](#how-to-use)
    * [Define model](#define-model)
    * [Create the instances](#create-the-instance-of-table-view-and-provider-you-choosel)
    * [Setup](#setup-provider)
    * [Show items](#show-items-in-table-view)
    * [Basic sample](#all-together)
*  [Features](#features)
    *  [Table View Provider](#table-view-providers)
    *  [Collection View Provider](#collection-view-provider)
*  [Animations](#animating-differences)
*  [Are you missing something?](#are-you-missing-something)
*  [Installation](#installation)
*  [License](#license)

## Why to use?
Writing simple scanario, where you want to use basic implementation of UITableView or UICollectionView is tedious. 
You have to implement a lot of delegate methods, even for the simplest case possible.
I
Example:  `UITableViewDiffableDataSource` accessible in iOS 13 as an simple approach of loading/diffing data in TableView 

Learning curve is a little bit tedious, but it's worth for the future programing.

Advantages:
- atomic data
- one source of truth
- no need to do custom diffing mechanism
- avoids synchronization bugs, exceptions and crashes
- avoids side effects
- uniform approach for the simple data provider, data provider using DeepDiff library or data provider using DiffableDataSource

Disadvantages:
- learning curve
- Not a good solution for complicated/advanced usage of the TableView or CollectionView
- different approach than standard Apple iOS API
- usage of third part diffing library DeepDiff
- only the most used delegates methods bridged to declarative way
- still in **development** process

Look at this simple code you just need to write:
```swift
lazy var tableProvider = DPSimpleTableViewProvider<Int> { _, tv, indexPath, item in
    guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: indexPath) else { return UITableViewCell() }
    cell.titleLabel.text = "Item with value: \(item)"
    return cell
}

private func showItems() {
    tableView.items(tableProvider, items: [1, 2, 3, 4, 5, 6, 7], animated: true)
}
```
That's all you need to do, when showing simple data in the TableView. 
Isn't it great? That's all you need to do. 

No need of:
- assigning `tableView.delegate = self` & `tableView.dataSource = self` 
- implementation of any DataSource/Delegate methods
- No need of casting/accessing the cell item property in collections (Arrays etc.)


## How to use?

You can use this type of DPProviders:
1. `DPSimpleTableViewProvider` -> use in case you have just one section in your TableView
2. `DPTableViewProvider` -> Default provider for the TableView
3. `DPDIffableTableViewProvider` -> Inherits all functionality of `DPTableViewProvider` but uses `UITableViewDiffableDataSource` API for diffing
4. `DeepDiffTableViewProvider` -> Inherits all functionality of `DPTableViewProvider` but uses `DeepDiff` framework for diffing. More info about framework, [click here](https://github.com/onmyway133/DeepDiff)
4. `DPCollectionViewProvider` -> Default provider for the CollectionView

### Define model 
Firstly you need to model your data, showed in the TableView or CollectionView using any type you choose.

For example:

```swift
///using Enum as Section & Class as Item
enum Section: Sectionable {
        
    case sectionOne([Item])
    case sectionTwo([Item])

    struct Item {
        let title: String       
    }
    
}

///using Class as Section & Enum as Item
class Section: Sectionable {
    let items: [Item]
    
    enum Item {
        case title
        case divider
        case advertisement
    }
    
}

///Define only items without sections
enum Item {
    case title
    case divider
    case advertisement
}

```
You can model it, based on your preference. 

### Create the instance of table view and provider you choose

```swift

@IBOutlet weak var tableView: UITableView!
private let tableProvider = DPSimpleTableViewProvider<Item>()

```

### Setup you provider

```swift

private func setupTableProvider() {            
    tableProvider.configureCell = { provider, tableView, index, item in              
        switch title {
        case .advertisement:
        return tableView.dequeueReusableCell(....)
        case .divider:
        return tableView.dequeueReusableCell(....)
        case .title:
        return tableView.dequeueReusableCell(....)
        }                   
    }
}

```

### Show items in table view

```swift

private func showItems() {            
    let items: [Item] = [.title,
                         .divider,
                         .advertisement,
                         .divider,
                         .advertisement]
                         
    tableProvider.bind(to: tableView, items: items)
}

```
🔥 That's it. All you need to do to show simple list with 2 advertisements and title in few lines of code. 🔥

### All together
Show list of strings in table view.
```swift

import UIKit
import DPProvider

class SimpleTableViewSampleController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let tableProvider = DPSimpleTableViewProvider<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Simple Table View Provider"
        
        setupTableView()
        showItems()
    }

    private func setupTableView() {
        tableProvider.estimatedHeightForRow = 100
                
        tableProvider.configureCell = { _, tv, index, title in
            guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: index) else { return UITableViewCell() }
            cell.titleLabel.text = title
            return cell
        }
    }
    
    private func showItems() {
        let items = (1...10).map { "Item \($0)" }
        tableProvider.bind(to: tableView, items: items)
    }
    
}

```

>[!WARNING]
> ⚠️⚠️⚠️  **Retain cycle**: Be careful when using strong reference inside closure. In case you need to call  ```self``` inside the closure, don't forget to use ```[unowned self]``` or ```[weak self]```

## Features
### Table view providers

You can choose one of these types of providers

1. `DPSimpleTableViewProvider` -> use in case you have just one section in your TableView
2. `DPTableViewProvider` -> Default provider for the TableView
3. `DPDIffableTableViewProvider` -> Inherits all functionality of `DPTableViewProvider` but uses `UITableViewDiffableDataSource` API for diffing
4. `DPDeepDiffTableViewProvider` -> Inherits all functionality of `DPTableViewProvider` but uses `DeepDiff` framework for diffing. More info about framework, [click here](https://github.com/onmyway133/DeepDiff)

Common features:

1.  `estimatedHeightForRow: CGFloat`   
Setup default estimated height of the dequeued cell.
2. `configureEstimatedCellHeight: CellHeightProvider` 
You can provide different height estimation for each cell separatelly.

```swift
tableProvider.configureEstimatedCellHeight = { _, _, _, item in
    switch item {
    case .advertisement:
        return 100
    case .divider:
        return 1
    case .title:
        return 24
    }
}
```
3.`configureCellHeight: CellHeightProvider` 
You can provide different height for each cell separatelly.
```swift
tableProvider.configureCellHeight = { _, _, _, item in
    switch item {
    case .advertisement:
    return UITableView.automaticDimension
    case .divider:
        return 1
    case .title:
        return 24
    }
}
```
4. `configureCell: CellProvider`
Configuration for dequeueing cell based on the model provided in provider instance definition.
```swift
tableProvider.configureCell = { provider, tableView, index, item in              
    switch title {
    case .advertisement:
    return tableView.dequeueReusableCell(....)
    case .divider:
    return tableView.dequeueReusableCell(....)
    case .title:
    return tableView.dequeueReusableCell(....)
    }                   
}
```
5. `configureSectionHeader: SectionHeaderFooterProvider` & `configureSectionFooter: SectionHeaderFooterProvider`
Return UIView showed in the header or footer.

```swift
tableProvider.configureSectionHeader = { provider, section in
    let container = UIView()
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(label)

    label.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
    label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 15).isActive = true
    label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15).isActive = true
    label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -15).isActive = true

    label.text = provider.sections[section].title

    return container
}
```
> ⚠️ Don't forget to setup height of the header. Ex: ```tableProvider.heightForHeaderInSection = UITableView.automaticDimension```

6. `configureSectionHeaderHeight: SectionHeaderFooterHeightProvider`  &  `configureSectionFooterHeight: SectionHeaderFooterHeightProvider` & `heightForFooterInSection: CGFloat` & `heightForHeaderInSection: CGFloat`
You can use one of the property fro mthe list about to configure height for footer or header in section. In case you want to have different sizes use `configure` method. Otherwise use other `heightForFooterInSection` and `heightForHeaderInSection`.
7. `configureOnItemSelected: ItemSelectionProvider`
One of the most used property in provider. Did you click the cell in the list? Setup this closure and you will be notified.
```swift
tableProvider.configureOnItemSelected = { [unowned self] _, _, _, item in
    switch item {
    case .advertisement:
        print("Advertisement clicked")
    case .divider:
        print("Advertisement clicked")
    case .title:
        print("Title clicked")
    }
}
```
8. `configureTrailingSwipeGesture: SwipeGestureProvider` & `configureLeadingSwipeGesture: SwipeGestureProvider`
10. `configureDidScroll: ScrollProvider`
9. `configureRefreshGesture: ScrollProvider`
Closure is notified, when the table view contains the refresh control. When `scrollViewDidEndDragging` executes, it autmatically checks the refresh control `isRefreshing` property and fires the event.
10. `configureDidEndDragging: DidEndDraggingProvider`
11. `configureWillEndDragging: WillEndDraggingProvider`

### Collection view providers

Right know, we have only one 2 types of CollectionViewProvider

1. `DPCollectionViewProvider` -> Default provider for the CollectionView
2. `DPDeepDiffCollectionViewProvider` -> Inherits all functionality of `DPCollectionViewProvider` but uses `DeepDiff` framework for diffing. More info about framework, [click here](https://github.com/onmyway133/DeepDiff)

Common features:

1. `configureCell: ItemProvider`
2. `configureCellSize: ItemSizeProvider`
3. `configureSupplementaryElementOfKind: SupplementaryViewProvider`
4. `configureSectionInsets: SectionInsetProvider`
5. `configureMinLineSpacingForSection: MinLineSpacingProvider`
6. `configureMinInteritemSpacingForSection: MinLineSpacingProvider`
7. `configureOnItemSelected: ItemSelectionProvider`
8. `configureDidScroll: ScrollProvider`
9. `configureRefreshGesture: ScrollProvider`
10. `configureWillEndDragging: WillEndDraggingProvider` & `configureDidEndDragging: DidEndDraggingProvider`
11. `cellSize: CGSize`
12. `sectionInsets: UIEdgeInsets`
13. `minimumLineSpacingForSection: CGFloat` 
14. `minInteritemSpacingForSection: CGFloat`


## Animating differences 

### DPDeepDiffTableViewProvider 
DeepDiff is a framework, used in past few years without problem. It's fast with great benchmark against other alghoritms. More about the library and alhgoritm you can find [here](https://github.com/onmyway133/DeepDiff).

It works simillarly to `DPDIffableTableViewProvider`, with same API but....

#### What is different?

1. You Section/Item model definition must comform to `DiffAware` protocol
2. Constructor **doesn't** require instance of the TableView unlike `DeepDiffTableViewProvider`.
3. You can modify the animation for insertion, deletion and replacement what is not currently possible in `DeepDiffTableViewProvider`
4. Available for all versions of iOS starting iOS 11

![](Resources/DeepDiff.gif)

### DPDIffableTableViewProvider #iOS13
Apple has released new API for animating differences in table views and collection views called `UITableViewDiffableDataSource`.
You can find documentation [here](https://developer.apple.com/documentation/uikit/uitableviewdiffabledatasource).

DPProvider uses it's benefits and provides you an custom implementation: `DPDIffableTableViewProvider`.
It uses the same API as other providers, so you don't need to worry about learning curve. All providers shares their API.

#### What is different?

1. You Section/Item model definition must comform to `Hashable` protocol
2. Constructor of the `DPDIffableTableViewProvider` requires instance of the TableView you will use in items binding.

There 2 things are required to animate your items differences in the table view. 

![](Resources/Diffable.gif)

### DPDeepDiffCollectionViewProvider 
Similar to [this section](#DPDeepDiffTableViewProvider)

![](Resources/DeepDiffCollection.gif)

## Are you missing something?

Just subclass one of the provider and create addtional functionality. It's that simple.

> ⚠️ Be careful of overriding the current functionality. Use `super` to prevent mistakes. 

### For example

```swift
class CustomSimpleTableViewProvider<Section: Sectionable>: DPTableViewProvider<Section> {
    
    open var configureDidHighlightRow: ((CustomSimpleTableViewProvider, UITableView, Section.Item) -> ())?
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        configureDidHighlightRow?(self, tableView, sections[indexPath.section].items[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows for section: \(section)")
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
}
```

# Installation
## Swift Package Manager

Create a `Package.swift` file.

```swift

import PackageDescription

let package = Package(
    name: "SampleProject",
    dependencies: [
        .Package(url: "https://github.com/smajdalf/DPProvider" from: "0.0.1")
    ]
)

```
If you are using Xcode 11 or higher, go to File / Swift Packages / Add Package Dependency... and enter package repository URL https://github.com/smajdalf/DPProvider, then follow the instructions

# License
DPProvider is released under the MIT license. See [LICENSE](LICENSE.md) for details.

