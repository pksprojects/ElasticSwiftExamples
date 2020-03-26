import ElasticSwift
import Kitura
import KituraOpenAPI
// import ElasticSwiftNetworking

public class App {
    let router = Router()

    let esClient: ElasticClient

    public init() throws {
//        let settings = Settings(forHost: "http://localhost:9200", withCredentials: BasicClientCredential(username: "elastic", password: "elastic"), adaptorConfig: URLSessionAdaptorConfiguration.default)
        let settings = Settings.default("http://localhost:9200")
        esClient = ElasticClient(settings: settings)
    }

    func postInit() throws {
        initializeCodableRoutes(app: self)
        KituraOpenAPI.addEndpoints(to: router)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
