import UIKit

protocol WaypointConfirmationViewControllerDelegate: NSObjectProtocol {
    func confirmationControllerDidConfirm(_ controller: WaypointConfirmationViewController)
}

class WaypointConfirmationViewController: UIViewController {

    weak var delegate: WaypointConfirmationViewControllerDelegate?
    
    lazy var button: UIButton = {
    let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue to next dextination", for: .normal)
        return button
    }()
    
    override func loadView() {
       super.loadView()
        view.backgroundColor = .white
        view.addSubview(button)
        let safeArea = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
      
        button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
    }
    
    @objc func tappedButton(sender: UIButton) {
        delegate?.confirmationControllerDidConfirm(self)
    }
}
