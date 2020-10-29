//
//  DiffableViewController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit
import GRProvider
import DeepDiff

fileprivate struct StepConfigurator {
    let sections: [Section]
}

final class TableProviderItemsGeneratorSlider: UISlider {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isContinuous = true
        addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    }
    fileprivate var currentIndex = 1
    fileprivate var steps: [StepConfigurator] = []
    
    fileprivate var onStepChanged: ((Int, StepConfigurator) -> ())?
    
    fileprivate func configure(steps: [StepConfigurator]) {
        self.maximumValue = Float(steps.count)
        self.steps = steps
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let roundedValue = round(sender.value / 1) * 1
        sender.value = roundedValue
        
        let index = Int(roundedValue)
        guard currentIndex != index  else { return }
        currentIndex = index
        onStepChanged?(index, steps[index - 1])
    }
    
}

fileprivate struct Section: Sectionable, DiffAware {
    
    struct Item: DiffAware {
        
        let title: String
        var diffId: String? {
            return title
        }
        
        init(title: String) {
            self.title = title
        }
        
        static func compareContent(_ a: Item, _ b: Item) -> Bool {
            a.title == b.title
        }
    }
    
    var items: [Item]
    var title: String?
              
    init(items: [Item], title: String?) {
        self.items = items
        self.title = title
    }
    
    var diffId: String? {
        return title
    }
    
    static func compareContent(_ a: Section, _ b: Section) -> Bool {
        a.title == b.title
    }
    
}

final class DeepDiffTableProviderSampleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slider: TableProviderItemsGeneratorSlider!
    @IBOutlet weak var stepLabel: UILabel!
    
    fileprivate lazy var tableProvider = GRDeepDiffTableViewProvider<Section>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DeepDiff Table View Provider"
        
        setupTableView()
        setupStepper()
    }
    
    private func setupTableView() {
        tableProvider.heightForHeaderInSection = 60
        tableProvider.estimatedHeightForRow = 100
        
        tableProvider.configureCell = { _, tv, indexPath, item in
            guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: indexPath) else { return UITableViewCell() }
            cell.titleLabel.text = item.title
            return cell
        }
        
        tableProvider.configureSectionHeader = { _, _, _, section in
            let container = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(label)

            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15).isActive = true
            label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -15).isActive = true

            label.text = section.title

            return container
        }
    
        tableProvider.configureOnItemSelected = { [unowned self] _, _, _, item in
            let alert = UIAlertController(title: "Wow!", message: "You clicked an item: \(item)", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    private func setupStepper() {
        let steps = generateSteps()
        slider.configure(steps: steps)
        
        slider.onStepChanged = { [weak self] in
            guard let `self` = self else { return }
            self.tableProvider.bind(to: self.tableView, sections: $1.sections)
            self.stepLabel.text = "Step \($0)/\(steps.count)"
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.tableProvider.bind(to: self.tableView, sections: steps[0].sections)
            self.stepLabel.text = "Step 1/\(steps.count)"
        }
        
    }
    
    private func generateSteps() -> [StepConfigurator] {
        var steps: [StepConfigurator] = []
        
        let section1Step1 = Section(items: (1...5).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section3Step1 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step1, section3Step1]))
        
        let section1Step2 = Section(items: (1...5).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2Step2 = Section(items: (6...9).map { Section.Item(title: "Item \($0)") }, title: "Section 1/5")
        let section3Step2 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        steps.append(.init(sections: [section1Step2, section2Step2, section3Step2]))
        
        let section1Step3 = Section(items: (1...2).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2Step3 = Section(items: (6...9).map { Section.Item(title: "Item \($0)") }, title: "Section 1/5")
        let section3Step3 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
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
