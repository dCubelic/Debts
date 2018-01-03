//
//  DebtCategoryTableViewCell.swift
//  Debts
//
//  Created by dominik on 03/01/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import UIKit

class DebtCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setup(with debtCategory: DebtCategory) {
        titleLabel.text = debtCategory.name
        detailLabel.text = String(debtCategory.totalDebt)
        
        let people = RealmHelper.getPersons(for: debtCategory).map { $0.person }
        
        if(people.count > 2) {
            subtitleLabel.text = "\(people.count) people"
        } else {
            var peopleString = ""
            for person in people {
                peopleString += person.name
                peopleString += ", "
            }
            peopleString.removeLast()
            peopleString.removeLast()
            subtitleLabel.text = peopleString
        }
    }

}
