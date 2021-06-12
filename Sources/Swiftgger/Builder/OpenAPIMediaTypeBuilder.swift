//
//  OpenAPIObjectReferenceBuilder.swift
//  Swiftgger
//
//  Created by Marcin Czachurski on 24.03.2018.
//

import Foundation
import AnyCodable

/// Builder of `paths` part of OpenAPI.
class OpenAPIMediaTypeBuilder {
    let objects: [APIObject]
    let type: APIResponseType

    init(objects: [APIObject], for type: APIResponseType) {
        self.objects = objects
        self.type = type
    }

    func built() -> OpenAPIMediaType {
        var openAPISchema: OpenAPISchema?
        
        switch type {
        case .object(let type, let isCollection):
            let objectTypeReference = self.createObjectReference(for: type)
            
            if isCollection {
                let objectInArraySchema = OpenAPISchema(ref: objectTypeReference)
                openAPISchema = OpenAPISchema(type: APIDataType.array.type, items: objectInArraySchema)
            } else {
                openAPISchema = OpenAPISchema(ref: objectTypeReference)
            }
            
            break
        case .value(let type):
            let example = AnyCodable(type)

            if let items = type as? Array<Any>, let first = items.first {
                let dataType = APIDataType(fromSwiftValue: first)
                
                let objectInArraySchema = OpenAPISchema(type: dataType?.type, format: dataType?.format)
                openAPISchema = OpenAPISchema(type: APIDataType.array.type, items: objectInArraySchema, example: example)
            } else {
                let dataType = APIDataType(fromSwiftValue: type)
                openAPISchema = OpenAPISchema(type: dataType?.type, format: dataType?.format, example: example)
            }
            
            break
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
