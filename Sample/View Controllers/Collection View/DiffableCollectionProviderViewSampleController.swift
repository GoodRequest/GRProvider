//
//  DiffableCollectionProviderViewSampleController.swift
//  Sample
//
//  Created by Marek Spalek on 29/10/2020.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit
import GRProvider

final class DiffableCollectionProviderViewSampleController: UIViewController {
    
    private typealias Section = DiffableSection
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var slider: DiffableItemsGeneratorSlider!
    @IBOutlet weak var stepLabel: UILabel!
    
    fileprivate lazy var provider = GRDiffableCollectionViewProvider<DiffableSection>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupStepper()
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        
        provider.configureSupplementaryElementOfKind = { provider, cv, index, type in
            debugPrint(type)
            let section = provider.sections[index.section]
            let view = cv.dequeueReusableSupplementaryView(ofKind: type, fromClass: SimpleCollectionViewSupplementaryView.self, for: index)
            view.titleLabel.text = section.title
            return view
        }

        provider.configureCell = { _, tv, indexPath, item in
            let cell = tv.dequeueReusableCell(fromClass: SimpleCollectionViewCell.self, for: indexPath)
            cell.titleLabel.text = item.title
            return cell
        }

        provider.configureOnItemSelected = { [unowned self] _, _, _, item in
            let alert = UIAlertController(title: "Wow!", message: "You clicked an item: \(item)", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        provider.bindCollectionView(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        configuration.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (index, environment) -> NSCollectionLayoutSection? in
            switch index % 3 {
            case 0:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalWidth(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                                       heightDimension: .fractionalWidth(0.25))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                          subitems: [item])
                return self.layoutSection(group: group)
            case 1:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(0.45))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                                       heightDimension: .fractionalWidth(0.7))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             subitems: [item])
                group.interItemSpacing = .fixed(10)
                return self.layoutSection(group: group)
            case 2:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(40))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
                                                       heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             subitem: item,
                                                             count: 5)
                group.interItemSpacing = .fixed(10)
                return self.layoutSection(group: group)
            default:
                return nil
            }
        }, configuration: configuration)
        
        return layout
    }
    
    func layoutSection(group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 10, bottom: 0, trailing: 10)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        
        let suppItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(30))
        let suppItemPlace = NSCollectionLayoutAnchor(edges: [.top, .leading])
        let suppItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: suppItemSize,
                                                                   elementKind: UICollectionView.elementKindSectionHeader,
                                                                   containerAnchor: suppItemPlace)
        section.boundarySupplementaryItems = [suppItem]
        
        return section
    }
    
    private func setupStepper() {
        let steps = generateSteps()
        slider.configure(steps: steps)

        slider.onStepChanged = { [weak self] (step, configurator) in
            guard let `self` = self else { return }
            
            UIView.animate(withDuration: 0.6) {
                self.provider.apply(configurator.sections)
            }
            self.stepLabel.text = "Step \(step)/\(steps.count)"
        }

        DispatchQueue.main.async { [unowned self] in
            self.provider.apply(steps[0].sections)
            self.stepLabel.text = "Step 1/\(steps.count)"
        }
    }
    
    private func generateSteps() -> [DiffableStepConfigurator] {
        var steps: [DiffableStepConfigurator] = []
        
        let section1Step1 = Section(items: (1...5).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section3Step1 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step1, section3Step1]))
        
        let section1Step2 = Section(items: (1...5).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2Step2 = Section(items: (6...12).map { Section.Item(title: "Item \($0)") }, title: "Section 1/5")
        let section3Step2 = Section(items: (12...14).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step2, section2Step2, section3Step2]))
        
        let section1Step3 = Section(items: (1...2).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2Step3 = Section(items: (6...12).map { Section.Item(title: "Item \($0)") }, title: "Section 1/5")
        let section3Step3 = Section(items: (10...14).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step3, section2Step3, section3Step3]))
        
        let section1Step4 = Section(items: (1...4).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2Step4 = Section(items: (6...7).map { Section.Item(title: "Item \($0)") }, title: "Section 1/5")
        let section3Step4 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step4, section2Step4, section3Step4]))
        
        let section1Step5 = Section(items: (1...4).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section3Step5 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step5, section3Step5]))
        steps.append(.init(sections: [section3Step5, section1Step5]))
                
        let section3Step7 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section3Step7]))
                
        let section3Step8 = Section(items: (10...12).reversed().map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section3Step8]))
        
        steps.append(.init(sections: []))
        
        return steps
    }
    
}
