import UIKit

class PersonDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineView: UIView!
    
    @IBOutlet weak var totalDebtLabel: UILabel!
    @IBOutlet weak var numberOfDebtsLabel: UILabel!
    
    var person: Person?
    var debts: [Debt] = []
    
    var keyboardObserver: NSObjectProtocol? = nil
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
//                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                
                if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
                    self.tableViewBottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY - tabBarHeight
                }
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        guard let person = person else { return }
        
        navigationController?.navigationBar.tintColor = UIColor(for: person)
        underlineView.backgroundColor = UIColor(for: person)
        title = person.name

        tableView.register(UINib(nibName: Constants.personDetailCell, bundle: nil), forCellReuseIdentifier: Constants.personDetailCell)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadDebtCategories()
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let person = person else { return }
        
        let alert = UIAlertController(title: "Delete all debts", message: "Are you sure you wish to remove all \(person.name)'s debts?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            RealmHelper.removeDebts(for: person)
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func reloadDebtCategories() {
        guard let person = person else { return }
        
        debts = RealmHelper.getDebts(for: person)
        
        totalDebtLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            person.totalDebt,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        numberOfDebtsLabel.text = "\(person.debts.count) debt\(person.debts.count == 1 ? "" : "s")"
        
        tableView.reloadData()
    }
    
    
}

extension PersonDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.personDetailCell, for: indexPath) as! PersonDetailTableViewCell
        
        cell.delegate = self
        cell.setup(with: debts[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            RealmHelper.removeDebt(self.debts[indexPath.row])
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            
            completionHandler(true)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nCost") { (action, view, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! PersonDetailTableViewCell
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)

            cell.editCost()
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
}

extension PersonDetailViewController: PersonDetailTableViewCellDelegate {
    func personDetailTableViewCell(_ cell: PersonDetailTableViewCell, didUpdateCost cost: Double) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        RealmHelper.changeCost(for: debts[indexPath.row], cost: cost)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
    }
}
