import XCTest
import RxSwift
import RxBlocking
import RxRelay

@testable import GitHub_Search

final class RepositoryListViewModelTests: XCTestCase {
    
    var sut: RepositoryListViewModel!
    var mockAPIService: MockApiService!
    var mockSceneCoordinator: MockSceneCoordinator!
    var disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        self.mockAPIService = MockApiService()
        self.mockSceneCoordinator = MockSceneCoordinator()
        
        self.sut = RepositoryListViewModel(coordinator: mockSceneCoordinator, apiService: mockAPIService)
    }

    override func tearDownWithError() throws {
        disposeBag = DisposeBag()
        
        self.sut = nil
        self.mockAPIService = nil
        self.mockSceneCoordinator = nil
        
        try super.tearDownWithError()
    }

    func testFetchRepositoriesCalled() {
        // Given.
        mockAPIService.repositoriesFetchResult = .success(Repositories(items: []))
        
        // When.
        sut.searchTextInput.accept("x")
        sut.repositoriesOutput.subscribe().disposed(by: disposeBag)
        
        // Assert.
        XCTAssert(mockAPIService.isFetchRepositoriesCalled)
    }
    
    func testFetchRepositoriesNotCalled() {
        // Given.
        mockAPIService.repositoriesFetchResult = .success(Repositories(items: []))
        
        // When.
        sut.searchTextInput.accept("")
        sut.repositoriesOutput.subscribe().disposed(by: disposeBag)
        
        // Assert.
        XCTAssert(!mockAPIService.isFetchRepositoriesCalled)
    }
    
    func testFetchRepositoriesFail() {
        // Given.
        let error = MockApiError.noNetwork
        mockAPIService.repositoriesFetchResult = .failure(error)
        
        // When.
        sut.searchTextInput.accept("x")
        sut.repositoriesOutput.subscribe().disposed(by: disposeBag)
        
        // Assert.
        XCTAssertEqual( try sut.errorOutput.toBlocking().first() as? MockApiError, error)
    }
    
    func testFetchRepositoriesSuccess() {
        // Given.
        let repositories = StubGenerator().stubRepositories()
        mockAPIService.repositoriesFetchResult = .success(repositories)
        
        // When
        sut.searchTextInput.accept("x")
        var result: [Repository]!
        sut.repositoriesOutput
            .subscribe(onNext: {repositories in
                result = repositories}
            )
            .disposed(by: disposeBag)
        
        // Assert number of cell view model is equal to the number of photos
        XCTAssertEqual( result.count, repositories.items.count )
    }
    
    func testFetchAvatarFail() {
        // Given.
        let repositories = StubGenerator().stubRepositories()
        let mockError = MockApiError.noNetwork
        mockAPIService.avatarImageDataFetchResult = .failure(mockError)
        
        // When.
        var error: Error?
        sut.fetchAvatarImageData(for: repositories.items.first!)
            .subscribe(onError: {err in
                error = err
            })
            .disposed(by: disposeBag)
        
        // Assert.
        XCTAssertEqual(mockError, error as? MockApiError)
    }
    
    func testFetchAvatarDataSuccess() {
        // Given.
        let repositories = StubGenerator().stubRepositories()
        mockAPIService.avatarImageDataFetchResult = .success(Data())
        
        // When.
        var result: Data?
        sut.fetchAvatarImageData(for: repositories.items.first!)
            .subscribe(onNext: {data in
                result = data
            })
            .disposed(by: disposeBag)
        
        // Assert.
        XCTAssert(result != nil)
    }
    
    func testItemSelected() {
        // Given.
        let repositories = StubGenerator().stubRepositories()
        let firstItem = repositories.items.first!
        mockAPIService.repositoriesFetchResult = .success(repositories)
        
        // When.
        sut.searchTextInput.accept("x")
        sut.repositoriesOutput.subscribe().disposed(by: disposeBag)
        Observable.just(firstItem).bind(to: sut.itemSelectedInputAction.inputs).disposed(by: disposeBag)
        
        // Assert.
        XCTAssertEqual( mockSceneCoordinator.didTransition, true )
    }
}

enum MockApiError: String, Error {
    case noNetwork = "No Network"
}

class MockApiService: APIServiceProtocol {
    var isFetchRepositoriesCalled = false
    var repositoriesFetchResult : Result<Repositories,Error>?
    var avatarImageDataFetchResult : Result<Data,Error>?
    
    // ezt nem hivjuk kozvetlen.
    func fetchRepositories(searchText: String) -> Observable<Repositories> {
        isFetchRepositoriesCalled = true
        
        switch repositoriesFetchResult! {
        case .success(let repositories):
            return Observable.just(repositories)
            
        case .failure(let error):
            return Observable.create { subscriber in
                subscriber.onError(error)
                return Disposables.create()
            }
        }
    }
    
    
    func fetchData(from url: URL) -> Observable<Data> {
        switch avatarImageDataFetchResult! {
        case .success(let data):
            return Observable.just(data)
            
        case .failure(let error):
            return Observable.create { subscriber in
                subscriber.onError(error)
                return Disposables.create()
            }
        }
    }
}

class MockSceneCoordinator: SceneCoordinatorType {
    var didTransition = false
    
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        didTransition = true
        
        return Completable.create { _ in
            Disposables.create()
        }
    }
    
    func pop(animated: Bool) -> RxSwift.Completable {
        return Completable.create { _ in
            Disposables.create()
        }
    }
}

class StubGenerator {
    func stubRepositories() -> Repositories {
        let path = Bundle.main.path(forResource: "content", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let repositories = try! decoder.decode(Repositories.self, from: data)
        return repositories
    }
}
