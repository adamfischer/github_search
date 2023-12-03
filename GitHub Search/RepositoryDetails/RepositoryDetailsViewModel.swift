import Foundation
import Action

class RepositoryDetailsViewModel {
    
    private let sceneCoordinator: SceneCoordinatorType
    let urlString: String
    
    init(coordinator: SceneCoordinatorType, urlString: String) {
        self.sceneCoordinator = coordinator
        self.urlString = urlString
    }
    
    lazy var dismissInputAction: Action<Void, Never> = {
        return Action {
            return self.sceneCoordinator
                .pop(animated: true)
                .asObservable()
        }
    }()
}
