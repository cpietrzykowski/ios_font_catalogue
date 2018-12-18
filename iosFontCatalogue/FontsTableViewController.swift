//
//  FontsTableViewController.swift
//  iosFontCatalogue
//
//  Created by Christopher Pietrzykowski on 2015-07-12.
//  Copyright (c) 2015 Zykix. All rights reserved.
//

import UIKit

// MARK: -
class FontNameTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var labelFont: UIFont? {
        didSet {
            self.activityView.stopAnimating()
            if labelFont != oldValue {
                self.nameLabel.font = labelFont
            }
        }
    }
}

// MARK: -
class FontItem {
    static let cache = NSCache<NSString, UIFont>()
    
    let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func font(fontSize: CGFloat, _ completion: @escaping (UIFont?) -> ()) {
        var rslt: UIFont? = nil
        let k = "\(self.name)\(fontSize)" as NSString
        if let cachedFont = type(of: self).cache.object(forKey: k) {
            rslt = cachedFont
        } else {
            if let newFont = UIFont.init(name: self.name, size: fontSize) {
                rslt = newFont
                type(of: self).cache.setObject(newFont, forKey: k)
            }
        }
        
        completion(rslt)
    }
}

// MARK: -
class FontFamilySection {
    let family: String
    let items: [FontItem]
    
    init(family: String) {
        self.family = family
        self.items = UIFont.fontNames(forFamilyName: family).map({ (name) -> FontItem in
            return FontItem.init(name)
        }).sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending })
    }
}

// MARK: -
class FontsTableViewController: UITableViewController {
    
    // table sections
    let sections: [FontFamilySection]
    
    required init?(coder aDecoder: NSCoder) {
        // load fonts to display
        self.sections = UIFont.familyNames.map({ (family) -> FontFamilySection in
            return FontFamilySection.init(family: family)
        }).sorted(by: { $0.family.localizedCaseInsensitiveCompare($1.family) == ComparisonResult.orderedAscending })
        
        // sort sections by family
        self.sections.sort(by: { $0.family < $1.family })
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let device = UIDevice.current
        self.navigationItem.title = "\(device.systemName) \(device.systemVersion) Fonts"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        return "\(section.family) (\(section.items.count))"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontNameCell", for: indexPath)
        
        if let fontCell = cell as? FontNameTableViewCell {
            let item = self.sections[indexPath.section].items[indexPath.row]
            fontCell.activityView.startAnimating()
            fontCell.nameLabel.text = item.name
            item.font(fontSize: 18.0) { (font) in
                DispatchQueue.main.async {
                    if let fontCell = tableView.cellForRow(at: indexPath) as? FontNameTableViewCell {
                        fontCell.labelFont = font
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Index Support
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Set(self.sections.map({ $0.family.prefix(1) })).map({ String($0) }).sorted(by: { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending })
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.sections.firstIndex(where: { $0.family.starts(with: title) }) ?? 0
    }
    
     // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let fontView = segue.destination as? FontTableViewController {
            if let selectedPath = self.tableView.indexPathForSelectedRow {
                fontView.item = self.sections[selectedPath.section].items[selectedPath.row]
            }
        }
    }
}
