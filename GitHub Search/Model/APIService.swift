import Foundation
import RxSwift

private enum Constants {
    static let baseURL = URL(string: "https://api.github.com/search/")!
}

protocol APIServiceProtocol {
    func fetchRepositories(searchText:String) -> Observable<Repositories>
    func fetchData(from url: URL) -> Observable<Data>
}

class APIService: APIServiceProtocol {
    
    func fetchRepositories(searchText:String) -> Observable<Repositories> {
        request(pathComponent: "repositories", params: [("q",searchText)] )
            // Uncomment to test slow fetch.
            //.delay(.milliseconds(2500), scheduler: MainScheduler.instance)
            .map { data in
                print(data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                return try decoder.decode(Repositories.self, from: data)
            }
    }
    
    func fetchData(from url: URL) -> Observable<Data> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        return session.rx.data(request: request)
    }

    private func request(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let url = Constants.baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            urlComponents.queryItems = queryItems
        } else {
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.data(request: request)
    }
}

