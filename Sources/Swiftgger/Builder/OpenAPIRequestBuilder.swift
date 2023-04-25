//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Builder for requests information stored in `paths` part of OpenAPI.
class OpenAPIRequestBuilder {
    let request: APIRequest?
    let objects: [APIObjectProtocol]

    init(request: APIRequest?, objects: [APIObjectProtocol]) {
        self.request = request
        self.objects = objects
    }

    func built() -> OpenAPIRequestBody? {
        guard let apiRequest = request, let apiRequestType = apiRequest.type else {
            return nil
        }

        let contentType: String

        switch apiRequestType {
        case .formdata:
            contentType = Constants.ContentType.formDataContentType
        default:
            contentType = apiRequest.contentType ?? "application/json"
        }

        let openAPIMediaTypeBuilder = OpenAPIMediaTypeBuilder(objects: objects, for: apiRequestType)
        let mediaType = openAPIMediaTypeBuilder.built()

        let requestBody = OpenAPIRequestBody(description: apiRequest.description, content: [contentType: mediaType])

        return requestBody
    }
}
