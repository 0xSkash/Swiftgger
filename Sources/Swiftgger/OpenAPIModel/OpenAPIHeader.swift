//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Information about additional headers supported by API server.
public class OpenAPIHeader: Codable {

    public private(set) var ref: String?
    public private(set) var name: String?
    public private(set) var parameterLocation: APILocation = APILocation.path
    public private(set) var description: String?
    public private(set) var required: Bool = false
    public private(set) var deprecated: Bool = false
    public private(set) var allowEmptyValue: Bool = false

    init(ref: String) {
        self.ref = ref
    }

    init(name: String, parameterLocation: APILocation = APILocation.path, description: String? = nil,
         required: Bool = false, deprecated: Bool = false, allowEmptyValue: Bool = false) {
        self.name = name
        self.parameterLocation = parameterLocation
        self.description = description
        self.required = required
        self.deprecated = deprecated
        self.allowEmptyValue = allowEmptyValue
    }

    private enum CodingKeys: String, CodingKey {
        case ref = "$ref"
        case name
        case parameterLocation = "in"
        case description
        case required
        case deprecated
        case allowEmptyValue
    }
}
