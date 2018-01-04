import UIKit

class PersonDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var underlineView: UIView!
    
    @IBOutlet weak var totalDebtLabel: UILabel!
    @IBOutlet weak var numberOfDebtsLabel: UILabel!
    
    var person: Person?
    var debtCategories: [DebtCategoryByPerson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let person = person else { return }
        
//        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = UIColor(for: person)
        underlineView.backgroundColor = UIColor(for: person)
        title = person.name
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: Constants.personDetailCell, bundle: nil), forCellReuseIdentifier: Constants.personDetailCell)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadDebtCategories()
    }
    
    @objc func reloadDebtCategories() {
        guard let person = person else { return }
        
        debtCategories = RealmHelper.getDebtCategories(for: person)
        
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
        return debtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.personDetailCell, for: indexPath) as! PersonDetailTableViewCell
        
        cell.setup(with: debtCategories[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}
