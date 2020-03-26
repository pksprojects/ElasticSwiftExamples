import Application
import Foundation
import HeliumLogger
import Kitura
import LoggerAPI

HeliumLogger.use()
do {
    let app = try App()
    try app.run()
} catch {
    Log.error(error.localizedDescription)
}
