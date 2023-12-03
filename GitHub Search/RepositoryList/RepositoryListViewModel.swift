import Foundation
import RxSwift
import RxRelay
import Action
import RxSwiftExt

class RepositoryListViewModel {
    private let sceneCoordinator: SceneCoordinatorType
    private let apiService: APIServiceProtocol
    
    // Inputs from View.
    let searchTextInput = BehaviorRelay<String>(value: "")
    lazy var itemSelectedInputAction: Action<Repository, Never> = {
        return Action { repository in
            
            let repositoryDetailsViewModel = RepositoryDetailsViewModel(coordinator: self.sceneCoordinator, urlString: repository.urlString)
            
            return self.sceneCoordinator
                .transition(to: Scene.repositoryDetails(repositoryDetailsViewModel),
                            type: .modal)
                .asObservable()
        }
    }()
    
    func fetchAvatarImageData(for repository: Repository) -> Observable<Data> {
        if let cachedData = repository.cachedAvatarImageData {
            return Observable.just(cachedData)
        }
        else if let urlString = repository.owner?.avatarURLString, let url = URL(string: urlString) {
            return self.apiService.fetchData(from: url)
                .observe(on: MainScheduler.instance)
                .do(onNext: { data in
                    repository.cachedAvatarImageData = data
                })
        }
        else {
            return Observable.create { subscriber in
                subscriber.onCompleted()
                return Disposables.create()
            }
        }
    }
    
    // Outputs to View.
    var repositoriesOutput : Observable<[Repository]>
    var errorOutput : Observable<Error>
    var requestInProgressOutput : Observable<Bool>
    
    init(coordinator: SceneCoordinatorType,apiService: APIServiceProtocol) {
        self.sceneCoordinator = coordinator
        self.apiService = apiService
        
        let filteredSearchInput = searchTextInput
            .filter { $0.count > 0 } // Don't search for an empty string.
        
        let search = filteredSearchInput
            .flatMapLatest { (text: String) -> Observable<Event<Repositories>> in
                apiService.fetchRepositories(searchText: text).materialize()
            }
            .share(replay: 1)
        
        let searchSuccess = search.elements()
        errorOutput = search.errors()
        
        self.repositoriesOutput = searchSuccess
            .map { $0.items }
        
        self.requestInProgressOutput = Observable.merge(
            filteredSearchInput.map { _ in true },
            search.map { _ in false }.asObservable()
        )
    }
}
