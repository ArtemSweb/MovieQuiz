import UIKit

final class AlertPresenter {
    private weak var delegate: UIViewController?

    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func createAlert(_ model: AlertModel) -> UIAlertController {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Game result"
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        return alert
    }
    
    func showAlert(model: AlertModel) {
        let alert = createAlert(model)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
