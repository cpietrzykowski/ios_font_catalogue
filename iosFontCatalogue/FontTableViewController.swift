//
//  FontTableViewController.swift
//  iosFontCatalogue
//
//  Created by Christopher Pietrzykowski on 2018-12-17.
//  Copyright © 2018 Zykix. All rights reserved.
//

import UIKit

class FontTableViewCell: UITableViewCell {
    @IBOutlet weak var sampleTextLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
}

class FontTableViewController: UITableViewController {
    
    var item: FontItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.item?.name
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 32
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Sample" : nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SampleCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath)
        }
        
        guard let item = self.item else {
            return cell
        }
        
        if let fontCell = cell as? FontTableViewCell {
            // typographic scale formula
            let fontSize = (6.0 * pow(2.0, (CGFloat(indexPath.row) / 5.0))).rounded()
            fontCell.sizeLabel.text = String(format: "%@ %dpt", item.name, Int(fontSize))
            fontCell.sampleTextLabel.text = "The quick brown fox jumps over the lazy dog"
            item.font(fontSize: fontSize, { (font) in
                fontCell.sampleTextLabel.font = font
            })
        } else {
            item.font(fontSize: UIFont.systemFontSize * 2.0) { (font) in
                cell.textLabel?.font = font
            }
        }
        
        return cell
    }
}
