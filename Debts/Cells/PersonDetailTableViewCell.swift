//import UIKit
//
//protocol PersonDetailTableViewCellDelegate: class {
//    func personDetailTableViewCell(_ cell: PersonDetailTableViewCell, didUpdateCost cost: Double)
//}
//
//class PersonDetailTableViewCell: UITableViewCell {
//
//    @IBOutlet weak var categoryView: UIView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var leftView: UIView!
//    @IBOutlet weak var detailLabel: UILabel!
//    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var costTextField: UITextField!
//    
//    weak var delegate: PersonDetailTableViewCellDelegate?
//    
//    let dateFormatter: DateFormatter = {
//        let df = DateFormatter()
//        df.dateFormat = "dd MMM yyyy"
//        return df
//    }()
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        selectionStyle = .none
//        
//        self.backgroundColor = .clear
//        
//        categoryView.layer.cornerRadius = 8
//        categoryView.clipsToBounds = true
//        categoryView.backgroundColor = UIColor(white: 246/255, alpha: 1)
//        
//        costTextField.isHidden = true
//        costTextField.delegate = self
//        costTextField.keyboardType = .decimalPad
//        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.2
//        layer.shadowOffset = CGSize.zero
//        layer.shadowRadius = 3
//        
//        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(editCost))
//        addGestureRecognizer(holdGesture)
//    }
//    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        if highlighted {
//            categoryView.backgroundColor = UIColor(white: 220/255, alpha: 1)
//        } else {
//            categoryView.backgroundColor = UIColor(white: 246/255, alpha: 1)
//        }
//    }
//    
//    func setup(with debt: Debt) {
//        guard let debtCategory = debt.debtCategory else { return }
//        
//        nameLabel.text = debtCategory.name
//        leftView.backgroundColor = UIColor(for: debtCategory)
//        dateLabel.text = dateFormatter.string(from: debt.dateAdded)
//        
//        detailLabel.text = String(
//            format: "%@%.2f%@",
//            Constants.currencyBeforeValue ? Constants.currency : "",
//            debt.cost,
//            Constants.currencyBeforeValue ? "" : Constants.currency
//        )
//       
//    }
//    
//    @objc func editCost() {
//        detailLabel.isHidden = true
//        costTextField.isHidden = false
//        costTextField.becomeFirstResponder()
//    }
//    
//}
//
//extension PersonDetailTableViewCell: UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.text = detailLabel.text?.replacingOccurrences(of: Constants.currency, with: "")
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
//        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
//        guard let cost = Double(text) else { return }
//        
//        detailLabel.text = String(
//            format: "%@%.2f%@",
//            Constants.currencyBeforeValue ? Constants.currency : "",
//            cost,
//            Constants.currencyBeforeValue ? "" : Constants.currency
//        )
//        
//        detailLabel.isHidden = false
//        costTextField.isHidden = true
//        
//        delegate?.personDetailTableViewCell(self, didUpdateCost: cost)
//    }
//    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        let text = (textField.text ?? "").replacingOccurrences(of: ",", with: ".")
//        guard let _ = Double(text) else { return false }
//        
//        if text.count == 0 {
//            return false
//        }
//        
//        return true
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let currentText = textField.text as NSString? else { return true }
//        let updatedText = currentText.replacingCharacters(in: range, with: string)
//        
//        let text = updatedText.replacingOccurrences(of: ",", with: ".")
//        if let _ = Double(text) {
//            return true
//        } else if text.count == 0 {
//            return true
//        }
//        
//        return false
//    }
//    
//}

