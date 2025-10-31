//
//  ItemsViewController.swift
//  LootLogger
//
//  Created by Eltonia Leonard on 10/31/25.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var itemStore: ItemStore!
    
    // Two sections: 0 = > $50, 1 = <= $50
    private enum Section: Int { case expensive = 0, regular = 1 }
    
    // Create quick views of the data for each section
    private var over50: [Item] { itemStore.allItems.filter { $0.valueInDollars > 50 } }
    private var upTo50: [Item] { itemStore.allItems.filter { $0.valueInDollars <= 50 } }
    
    // Track whether there are any items at all (Silver: constant row when empty)
    private var isEmpty: Bool { itemStore.allItems.isEmpty }
    
    @IBAction func addNewItem(_ sender: UIButton) {
        // Create a new item and add it to the store
        _ = itemStore.createItem()
        
        // Refresh the table so the item appears in the correct section
        tableView.reloadData()
    }

    @IBAction func toggleEditingMode(_ sender: UIButton) {
        // If you are currently in editing mode...
        if isEditing {
            // Change text of button to inform user of state
            sender.setTitle("Edit", for: .normal)

            // Turn off editing mode
            setEditing(false, animated: true)
        } else {
            // Change text of button to inform user of state
            sender.setTitle("Done", for: .normal)

            // Enter editing mode
            setEditing(true, animated: true)
        }
    }
    
    // Disable moving rows for this challenge
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Set number of sections in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Silver: when empty, show a single section containing the "No items!" row
        return isEmpty ? 1 : 2
    }
    
    // Set number of rows in cell
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // Silver: when empty, show exactly one row
        if isEmpty { return 1 }
        return section == Section.expensive.rawValue ? over50.count : upTo50.count
    }
    
    // Set section headers
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        // Silver: when empty, no headers
        if isEmpty { return nil }
        return section == Section.expensive.rawValue ? "Over $50" : "Up to $50"
    }
    
    // Configure cells
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
                                                 for: indexPath)

        if isEmpty {
            // Set the text on the cell when there are no items
            cell.textLabel?.text = "No items!"
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
            return cell
        }
        
        // Set the text on the cell with the description of the item
        // that is at the nth index of items for the correct section
        let item = (indexPath.section == Section.expensive.rawValue)
            ? over50[indexPath.row]
            : upTo50[indexPath.row]

        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "$\(item.valueInDollars)"
        return cell
    }
    
    // Support deleting rows
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            // Do nothing if there are no items (Silver: placeholder is not deletable)
            if isEmpty { return }
            
            // Get the item from the correct section
            let item = (indexPath.section == Section.expensive.rawValue)
                ? over50[indexPath.row]
                : upTo50[indexPath.row]

            // Remove the item from the store
            itemStore.removeItem(item)

            // Refresh the table so sections/rows update correctly
            tableView.reloadData()
        }
    }
    
    // Disallow editing controls when there are no items (no swipe-to-delete)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }
    

    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        // Update the model
        itemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

