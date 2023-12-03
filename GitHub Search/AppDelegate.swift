import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window

        let vc = RepositoryListViewController()
        window.rootViewController = vc
        
        let sceneCoordinator = SceneCoordinator(window: window)
        let apiService = APIService()
        
        // Initial View Model.
        let repositoryListViewModel = RepositoryListViewModel(coordinator: sceneCoordinator,apiService: apiService)
        let firstScene = Scene.repositoryList(repositoryListViewModel)
        
        // This creates initial VC, and binds a View Model to it.
        sceneCoordinator.transition(to: firstScene, type: .root)
        
        return true
    }
    
}

func appDelegate() -> AppDelegate {
    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
        fatalError("Could not get app delegate.")
    }
    return delegate
}

