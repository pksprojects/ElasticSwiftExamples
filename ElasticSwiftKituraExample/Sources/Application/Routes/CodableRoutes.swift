import ElasticSwift
import ElasticSwiftCore
import ElasticSwiftQueryDSL
import KituraContracts
import LoggerAPI

func initializeCodableRoutes(app: App) {
    // Register routes here
    app.router.get("/books", handler: app.queryGetHandler)
    app.router.post("/books", handler: app.postBookHandler)
}

extension App {
    static var codableStore = [Book]()
    // Write handlers here

    static let indexName = "books"

    func queryGetHandler(query: BookQuery, respondWith: @escaping ([Book]?, RequestError?) -> Void) {
        // Filter data using query parameters provided to the application
        do {
            let q: Query
            if let bookName = query.name {
                q = try QueryBuilders.matchQuery()
                    .set(field: "name")
                    .set(value: bookName)
                    .build()
            } else {
                q = MatchAllQuery()
            }
            let searchRequest = try SearchRequestBuilder()
                .set(query: q)
                .set(indices: App.indexName)
                .build()
            esClient.search(searchRequest) { (result: Result<SearchResponse<Book>, Error>) -> Void in
                switch result {
                case let .success(response):
                    return respondWith(response.hits.hits.map { $0.source! }, nil)
                case let .failure(error):
                    Log.error("\(String(describing: error))")
                    return respondWith(nil, RequestError.internalServerError)
                }
            }
        } catch {
            return respondWith(nil, RequestError.internalServerError)
        }
    }

    func postBookHandler(book: Book, completion: @escaping (Book?, RequestError?) -> Void) {
        let indexRequest = IndexRequest(index: App.indexName, id: book.name, source: book)
        esClient.index(indexRequest) { result in
            switch result {
            case let .success(response):
                Log.info("Success: \(String(describing: response))")
                completion(book, nil)
            case let .failure(error):
                Log.error("\(String(describing: error))")
                completion(nil, RequestError.internalServerError)
            }
        }
    }
}
