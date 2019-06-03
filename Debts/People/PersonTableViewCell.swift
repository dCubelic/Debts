import UIKit

protocol PersonTableViewCellDelegate: class {
    func personTableViewCellDidEndEditing(_ cell: PersonTableViewCell, name: String)
}

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var personView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nameTextField: UITextField!

    weak var delegate: PersonTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        self.backgroundColor = .clear

        personView.layer.cornerRadius = 8
        personView.clipsToBounds = true
        personView.backgroundColor = .cellBackgroundColor

        nameTextField.isHidden = true
        nameTextField.delegate = self

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            personView.backgroundColor = .cellBackgroundColorHighlighted
        } else {
            personView.backgroundColor = .cellBackgroundColor
        }
    }

    func setup(with person: Person) {
        titleLabel.text = person.name
        detailLabel.text = Currency.stringWithSelectedCurrency(for: abs(person.totalDebt))

        let color = UIColor(for: person)

        leftView.backgroundColor = color
        underlineView.backgroundColor = color

        if person.totalDebt < 0 {
            detailLabel.textColor = .red
        } else {
            detailLabel.textColor = .black
        }

        let debts = RealmHelper.getDebts(for: person)

        if debts.count == 1 {
            subtitleLabel.text = debts.first?.debtCategory?.name
        } else {
            subtitleLabel.text = "\(debts.count) debts"
        }
    }

    func editName() {
        nameTextField.text = titleLabel.text
        nameTextField.isHidden = false
        titleLabel.isHidden = true
        nameTextField.becomeFirstResponder()
    }
}

extension PersonTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let text = textField.text else { return }
        
        titleLabel.text = textField.text

        titleLabel.isHidden = false
        nameTextField.isHidden = true
        
        delegate?.personTableViewCellDidEndEditing(self, name: text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
