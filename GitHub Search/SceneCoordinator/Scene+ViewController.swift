import UIKit

extension Scene {
    func createViewControllerAndBindToViewModel() -> UIViewController {
        switch self {
        case .repositoryList(let viewModel):
            let viewController = RepositoryListViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.bindViewModel(to: viewModel)
            
            return navigationController
        case .repositoryDetails(let viewModel):
            let viewController = RepositoryDetailsViewController()
            viewController.bindViewModel(to: viewModel)
            
            return viewController
        }
    }
}
