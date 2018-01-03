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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        
        self.backgroundColor = .clear
//        contentView.backgroundColor = .clear
        
        categoryView.layer.cornerRadius = 8
        categoryView.clipsToBounds = true
        categoryView.backgroundColor = UIColor(white: 246/255, alpha: 1)
    }
    
    func setup(with debtCategory: DebtCategory, color: UIColor) {
        titleLabel.text = debtCategory.name
        dateLabel.text = dateFormatter.string(from: debtCategory.dateCreated)
        
        
        detailLabel.text = String(format: "%@%.2f%@",
                                  Constants.currencyBeforeValue ? Constants.currency : "",
                                  debtCategory.totalDebt,
                                  Constants.currencyBeforeValue ? "" : Constants.currency
        )
        
        leftView.backgroundColor = color
        underlineView.backgroundColor = color
        
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
