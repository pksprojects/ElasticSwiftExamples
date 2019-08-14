import KituraContracts
import ElasticSwift
import LoggerAPI
import ElasticSwiftCore
import ElasticSwiftQueryDSL

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
        let q: Query;
        if let bookName = query.name {
            q = QueryBuilders.matchQuery().set(field: "name").set(value: bookName).query
        } else {
            q = QueryBuilders.matchAllQuery().query
        }
        do {
            let searchRequest = try SearchRequestBuilder { builder in
                builder.set(query: q).set(indices: App.indexName)
            } .build()
            esClient.search(searchRequest) { (result: Result<SearchResponse<Book>, Error>) -> Void in
                switch result {
                case .success(let response):
                    return respondWith(response.hits.hits.map { $0.source! }, nil)
                case .failure(let error):
                    Log.error("\(String(describing: error))")
                    return respondWith(nil, RequestError.internalServerError)
                }
            }
        } catch {
            return respondWith(nil, RequestError.internalServerError)
        }
    }

    func postBookHandler(book: Book, completion: @escaping (Book?, RequestError?) -> Void ) {

        let indexRequest = IndexRequest(index: App.indexName, id: book.name, source: book)
        esClient.index(indexRequest) { result in
            switch result {
            case .success(let response):
                Log.info("Success: \(String(describing: response))")
                completion(book, nil)
            case .failure(let error):
                Log.error("\(String(describing: error))")
                completion(nil, RequestError.internalServerError)

            }
        }
    }
}
