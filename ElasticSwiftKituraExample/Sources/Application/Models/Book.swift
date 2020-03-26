//
// Created by prafsoni on 7/14/19.
//

import Foundation
import Kitura
import KituraContracts

// Book is a sample struct used in the Codable routes
public struct Book: Codable {
    // MARK: Properties

    var name: String
    var author: String
    var rating: Int
}

extension Book: Equatable {}

public struct BookQuery: QueryParams {
    public let name: String?
}
