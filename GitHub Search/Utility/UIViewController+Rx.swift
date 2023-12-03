import Foundation
import RxSwift
import UIKit

struct AlertAction {
    var title: String
    var style: UIAlertAction.Style
    
    static func action(title: String, style: UIAlertAction.Style = .default) -> AlertAction {
        return AlertAction(title: title, style: style)
    }
}

extension Reactive where Base: UIViewController {
    
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, actions: [AlertAction])
    -> Observable<Int> {
        return Observable.create { observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
            
            actions.enumerated().forEach { index, action in
                let action = UIAlertAction(title: action.title, style: action.style) { _ in
                    observer.onNext(index)
                    observer.onCompleted()
                }
                alertController.addAction(action)
            }
            
            base.present(alertController, animated: true, completion: nil)
            
            return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
        }
        .observe(on:MainScheduler.instance)
        .subscribe(on: MainScheduler.instance)
    }
}
