//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import AnyCodable
import Foundation

/// Builder of `paths` part of OpenAPI.
class OpenAPIMediaTypeBuilder {
    let objects: [APIObjectProtocol]
    let type: APIBodyType

    init(objects: [APIObjectProtocol], for type: APIBodyType) {
        self.objects = objects
        self.type = type
    }

    func built() -> OpenAPIMediaType {
        var openAPISchema: OpenAPISchema?

        switch type {
        case let .dictionary(type):
            if let dataType = APIDataType(fromSwiftType: type) {
                let additionalProperties = OpenAPISchema(type: dataType.type, format: dataType.format)
                openAPISchema = OpenAPISchema(type: "object", additionalProperties: additionalProperties)
            } else {
                let objectTypeReference = createObjectReference(for: type)
                let additionalProperties = OpenAPISchema(ref: objectTypeReference)
                openAPISchema = OpenAPISchema(type: "object", additionalProperties: additionalProperties)
            }

        case let .object(type, isCollection):
            let objectTypeReference = createObjectReference(for: type)

            if isCollection {
                let objectInArraySchema = OpenAPISchema(ref: objectTypeReference)
                openAPISchema = OpenAPISchema(type: APIDataType.array.type, items: objectInArraySchema)
            } else {
                openAPISchema = OpenAPISchema(ref: objectTypeReference)
            }

        case let .value(value):
            let example = AnyCodable(value)

            if let items = value as? [Any], let first = items.first {
                let dataType = APIDataType(fromSwiftValue: first)

                let objectInArraySchema = OpenAPISchema(type: dataType?.type, format: dataType?.format)
                openAPISchema = OpenAPISchema(type: APIDataType.array.type, items: objectInArraySchema, example: example)
            } else {
                let dataType = APIDataType(fromSwiftValue: value)
                openAPISchema = OpenAPISchema(type: dataType?.type, format: dataType?.format, example: example)
            }

        case let .formdata(name):
            openAPISchema = OpenAPISchema(
                type: "object",
                properties: [name: OpenAPISchema(type: "string", format: "binary")]
            )
        }

        let openAPIMediaType = OpenAPIMediaType(schema: openAPISchema)
        return openAPIMediaType
    }

    func createObjectReference(for type: Any.Type) -> String {
        let typeName = String(describing: type)

        guard let object = objects.first(where: { $0.defaultName == typeName }) else {
            return "#/components/schemas/\(typeName)"
        }

        let schemaTypeName = object.customName ?? object.defaultName
        return "#/components/schemas/\(schemaTypeName)"
    }
}
