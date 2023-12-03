import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

class RepositoryListViewController: UIViewController, BindableType {
    private let disposeBag = DisposeBag()
    
    var viewModel: RepositoryListViewModel!
    private let resultSearchController = UISearchController(searchResultsController: nil) // Pass nil if you wish to display search results in the same view that you are searching.
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GitHub Repository Search"
        self.noDataLabel.text = "No results were found."
        
        self.resultSearchController.searchBar.placeholder = "Enter search text here"
        self.resultSearchController.obscuresBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.returnKeyType = .search
        
        self.definesPresentationContext = true // Fixes issue where the search bar remains on the screen if the user navigates to another view controller while the UISearchController is active.

        initTableView()
        
        self.noDataLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resultSearchController.searchBar.becomeFirstResponder()
    }
    
    private func initTableView() {
        self.tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "macilaci")
        self.tableView.register(UINib.init(nibName: "RepositoryTableViewCell", bundle: nil), forCellReuseIdentifier: "macilaci")
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
    }
    
    func bindViewModel() {
        resultSearchController.searchBar.searchTextField.rx.controlEvent([.editingDidEnd])
            .map{_ in}
            .withLatestFrom(resultSearchController.searchBar.rx.text.orEmpty)
            .bind(to: viewModel.searchTextInput)
            .disposed(by: disposeBag)

        viewModel.requestInProgressOutput
            .observe(on: MainScheduler.instance)
            .bind(to:activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        let repositoriesOutput = viewModel.repositoriesOutput
            .observe(on: MainScheduler.instance)
            .share(replay:1)
        
        repositoriesOutput
            .map { $0.count == 0 }
            .bind(to:noDataLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        repositoriesOutput
            .do { repositories in
                    self.tableView.setContentOffset(.zero, animated: false)
            }
            .compactMap{ $0 }
            .bind(to:tableView.rx.items) { (tableView: UITableView, index: Int, repository: Repository) in
                let indexPath = IndexPath(item: index, section: 0)
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "macilaci", for: indexPath) as! RepositoryTableViewCell
                cell.nameLabel.text = repository.name
                cell.descriptionLabel.text = repository.description ?? "Missing description."
                cell.languageLabel.text = "Languages:"
                cell.languagesListLabel.text = repository.programmingLanguage ?? "Missing programming language."
                cell.starsLabel.text = "Starred:"
                cell.starsLabel.text = "Starred:"
                cell.starsCountLabel.text = "\(repository.stargazersCount)"
                cell.ownerLabel.text = "By \(repository.owner?.name ?? "Unknown")"
                
                self.viewModel.fetchAvatarImageData(for: repository)
                    .catchErrorJustComplete()
                    .observe(on:MainScheduler.instance)
                    .compactMap { UIImage(data: $0) }
                    .startWith(UIImage(named: "placeholder"))
                    .bind(to: cell.avatarImageView.rx.image)
                    .disposed(by: cell.disposeBag)

                return cell
            }
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .do(onNext: { [unowned self] indexPath in
                tableView.deselectRow(at: indexPath, animated: false)
            })
            .map { [unowned self] indexPath -> Repository in
                try! tableView.rx.model(at: indexPath)
            }
            .bind(to: viewModel.itemSelectedInputAction.inputs)
            .disposed(by: disposeBag)
        
        viewModel.errorOutput
            .flatMap { error -> Observable<Int> in
                self.rx.showAlert(title: "Error",
                                   message: error.localizedDescription,
                                   style: .alert,
                                   actions: [AlertAction(title: "OK", style: .default)])
            }
            .subscribe{ selectedItemIndex in
                print("Error dismissed, selectedItemIndex: \(selectedItemIndex)")
            }
            .disposed(by: disposeBag)
    }
}

