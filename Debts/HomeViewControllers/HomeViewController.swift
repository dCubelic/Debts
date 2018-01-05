import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineView2: UIView!
    @IBOutlet weak var newMyDebt: UIButton!
    @IBOutlet weak var newDebt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        homeView.layer.cornerRadius = 25
        homeView.backgroundColor = UIColor(white: 246 / 255, alpha: 1)
        
        underlineView.backgroundColor = UIColor.red
        underlineView2.backgroundColor = UIColor.yellow
        
        newMyDebt.layer.cornerRadius = 8
        newMyDebt.backgroundColor = UIColor(white: 230 / 255, alpha : 1)
        newDebt.layer.cornerRadius = 8
        newDebt.backgroundColor = UIColor(white: 230 / 255, alpha : 1)
    }

}
