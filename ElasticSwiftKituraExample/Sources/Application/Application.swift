import Kitura
import KituraOpenAPI
import ElasticSwift

public class App {

    let router = Router()

    let esClient: ElasticClient

    public init() throws {
        let settings = Settings.default
        self.esClient = ElasticClient(settings: settings)
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