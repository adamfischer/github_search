import UIKit
import RxSwift
import RxCocoa
import WebKit

class RepositoryDetailsViewController: UIViewController, BindableType {
    private let disposeBag = DisposeBag()
    var viewModel: RepositoryDetailsViewModel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: viewModel.urlString) {
            let req = URLRequest(url: url)
            webView.load(req)
        }
    }

    func bindViewModel() {
        doneButton.rx.tap
            .bind(to: viewModel.dismissInputAction.inputs)
            .disposed(by: disposeBag)
    }

}
