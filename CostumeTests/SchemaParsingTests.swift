//
//  SchemaParsingTests.swift
//  CostumeTests
//
//  Created by Saujana Shafi on 25/07/26.
//

import Foundation
import Testing

@testable import Costume

@Suite("Schema Parsing")
struct SchemaParsingTests {

    @Test("JobDescriptionGenerable schema has correct property names and types")
    func jobDescriptionSchemaProperties() throws {
        let schema = try SchemaBuilder.jsonSchema(
            for: JobDescriptionGenerable.self
        )

        guard
            case .object(
                let properties,
                let required,
                let additionalProperties,
                _,
                _
            ) = schema
        else {
            Issue.record("Expected object schema")
            return
        }

        #expect(
            Set(properties.keys)
                == Set([
                    "role", "company", "abstract", "responsibilities",
                    "requirements", "keywords",
                ])
        )
        #expect(
            required?.sorted() == [
                "abstract", "company", "keywords", "requirements",
                "responsibilities", "role",
            ]
        )
        #expect(additionalProperties == false)

        guard case .string = properties["role"]! else {
            Issue.record("role should be string")
            return
        }
        guard case .string = properties["company"]! else {
            Issue.record("company should be string")
            return
        }
        guard case .string = properties["abstract"]! else {
            Issue.record("abstract should be string")
            return
        }
        guard case .array = properties["responsibilities"]! else {
            Issue.record("responsibilities should be array")
            return
        }
        guard case .array = properties["requirements"]! else {
            Issue.record("requirements should be array")
            return
        }
        guard case .array = properties["keywords"]! else {
            Issue.record("keywords should be array")
            return
        }
    }

    @Test("Array item types are correctly inferred")
    func jobDescriptionArrayItemTypes() throws {
        let schema = try SchemaBuilder.jsonSchema(
            for: JobDescriptionGenerable.self
        )

        guard case .object(let properties, _, _, _, _) = schema else {
            Issue.record("Expected object schema")
            return
        }

        for key in ["responsibilities", "requirements", "keywords"] {
            guard case .array(let items, _, _) = properties[key]! else {
                Issue.record("\(key) should be array")
                continue
            }
            guard case .string = items else {
                Issue.record("\(key) items should be string")
                continue
            }
        }
    }

    @Test("SchemaDescribing descriptions are injected into schema")
    func jobDescriptionDescriptions() throws {
        var schema = try SchemaBuilder.jsonSchema(
            for: JobDescriptionGenerable.self
        )

        SchemaBuilder.enrichSchema(
            &schema,
            with: JobDescriptionGenerable.propertyDescriptions
        )

        guard case .object(let properties, _, _, _, _) = schema else {
            Issue.record("Expected object schema")
            return
        }

        #expect(properties["role"]?.description == JOB_DESCRIPTION_ROLE_V1)
        #expect(
            properties["company"]?.description == JOB_DESCRIPTION_COMPANY_V1
        )
        #expect(
            properties["abstract"]?.description == JOB_DESCRIPTION_ABSTRACT_V1
        )
        #expect(
            properties["responsibilities"]?.description
                == JOB_DESCRIPTION_RESPONSIBILITIES_V1
        )
        #expect(
            properties["requirements"]?.description
                == JOB_DESCRIPTION_REQUIREMENTS_V1
        )
        #expect(
            properties["keywords"]?.description == JOB_DESCRIPTION_KEYWORDS_V1
        )
    }

    @Test("Schema encodes to expected JSON format")
    func jobDescriptionSchemaJSON() throws {
        var schema = try SchemaBuilder.jsonSchema(
            for: JobDescriptionGenerable.self
        )
        SchemaBuilder.enrichSchema(
            &schema,
            with: JobDescriptionGenerable.propertyDescriptions
        )

        let body = JSONSchemaBody(
            name: "JobDescriptionGenerable",
            strict: true,
            schema: schema
        )
        let data = try JSONEncoder().encode(body)
        let json =
            try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "JobDescriptionGenerable")
        #expect(json["strict"] as? Bool == true)

        let schemaDict = json["schema"] as! [String: Any]
        #expect(schemaDict["type"] as? String == "object")
        #expect(schemaDict["additionalProperties"] as? Bool == false)

        let properties = schemaDict["properties"] as! [String: Any]
        #expect(properties["role"] as? [String: Any] != nil)
        #expect(properties["company"] as? [String: Any] != nil)
        #expect(properties["abstract"] as? [String: Any] != nil)
        #expect(properties["responsibilities"] as? [String: Any] != nil)
        #expect(properties["requirements"] as? [String: Any] != nil)
        #expect(properties["keywords"] as? [String: Any] != nil)

        let roleProp = properties["role"] as! [String: Any]
        #expect(roleProp["type"] as? String == "string")
        #expect(roleProp["description"] as? String == JOB_DESCRIPTION_ROLE_V1)

        let responsibilitiesProp =
            properties["responsibilities"] as! [String: Any]
        #expect(responsibilitiesProp["type"] as? String == "array")

        let required = schemaDict["required"] as! [String]
        #expect(required.contains("role"))
        #expect(required.contains("keywords"))
    }

    // MARK: - SectionsGenerable

    @Test("SectionsGenerable schema has correct property names and types")
    func sectionsGenerableSchemaProperties() throws {
        let schema = try SchemaBuilder.jsonSchema(
            for: SectionsGenerable.self
        )

        guard
            case .object(
                let properties,
                let required,
                let additionalProperties,
                _,
                _
            ) = schema
        else {
            Issue.record("Expected object schema")
            return
        }

        #expect(Set(properties.keys) == Set(["sections"]))
        #expect(required?.sorted() == ["sections"])
        #expect(additionalProperties == false)

        guard case .array(let items, _, _) = properties["sections"]! else {
            Issue.record("sections should be array")
            return
        }

        guard
            case .object(
                let sectionProperties,
                let sectionRequired,
                let sectionAdditional,
                _,
                _
            ) = items
        else {
            Issue.record("sections items should be object")
            return
        }

        #expect(
            Set(sectionProperties.keys)
                == Set(["title", "description", "keywords"])
        )
        #expect(
            sectionRequired?.sorted()
                == ["description", "keywords", "title"]
        )
        #expect(sectionAdditional == false)

        guard
            case .string(_, _, let enumValues, _) = sectionProperties[
                "title"
            ]!
        else {
            Issue.record("title should be string with enum")
            return
        }
        #expect(
            enumValues?.sorted()
                == [
                    "award", "certification", "education", "experience",
                    "language", "profile", "project", "skill", "summary",
                ]
        )

        guard case .string = sectionProperties["description"]! else {
            Issue.record("description should be string")
            return
        }

        guard case .array = sectionProperties["keywords"]! else {
            Issue.record("keywords should be array")
            return
        }
    }

    @Test("SectionGenerable array and nested items")
    func sectionGenerableArrayItemTypes() throws {
        let schema = try SchemaBuilder.jsonSchema(
            for: SectionGenerable.self
        )

        guard
            case .object(let properties, let required, _, _, _) = schema
        else {
            Issue.record("Expected object schema")
            return
        }

        #expect(
            Set(properties.keys)
                == Set(["title", "description", "keywords"])
        )
        #expect(required?.sorted() == ["description", "keywords", "title"])

        guard case .array(let items, _, _) = properties["keywords"]! else {
            Issue.record("keywords should be array")
            return
        }
        guard case .string = items else {
            Issue.record("keywords items should be string")
            return
        }
    }

    @Test("SectionsGenerable descriptions are injected into schema")
    func sectionsGenerableDescriptions() throws {
        var schema = try SchemaBuilder.jsonSchema(
            for: SectionsGenerable.self
        )

        SchemaBuilder.enrichSchema(
            &schema,
            with: SectionsGenerable.propertyDescriptions
        )

        guard
            case .object(let properties, _, _, _, _) = schema
        else {
            Issue.record("Expected object schema")
            return
        }

        #expect(
            properties["sections"]?.description == SECTIONS_LIST_V1
        )
    }

    @Test("SectionGenerable descriptions are injected into schema")
    func sectionGenerableDescriptions() throws {
        var schema = try SchemaBuilder.jsonSchema(
            for: SectionGenerable.self
        )

        SchemaBuilder.enrichSchema(
            &schema,
            with: SectionGenerable.propertyDescriptions
        )

        guard
            case .object(let properties, _, _, _, _) = schema
        else {
            Issue.record("Expected object schema")
            return
        }

        #expect(
            properties["title"]?.description == SECTION_TITLE_V1
        )
        #expect(
            properties["description"]?.description == SECTION_DESCRIPTION_V1
        )
        #expect(
            properties["keywords"]?.description == SECTION_KEYWORDS_V1
        )
    }

    @Test("SectionsGenerable schema encodes to expected JSON format")
    func sectionsGenerableSchemaJSON() throws {
        var schema = try SchemaBuilder.jsonSchema(
            for: SectionsGenerable.self
        )
        SchemaBuilder.enrichSchema(
            &schema,
            with: SectionsGenerable.propertyDescriptions
        )

        let body = JSONSchemaBody(
            name: "SectionsGenerable",
            strict: true,
            schema: schema
        )
        let data = try JSONEncoder().encode(body)
        let json =
            try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["name"] as? String == "SectionsGenerable")
        #expect(json["strict"] as? Bool == true)

        let schemaDict = json["schema"] as! [String: Any]
        #expect(schemaDict["type"] as? String == "object")
        #expect(schemaDict["additionalProperties"] as? Bool == false)

        let properties = schemaDict["properties"] as! [String: Any]
        let sectionsProp = properties["sections"] as! [String: Any]
        #expect(sectionsProp["type"] as? String == "array")
        #expect(
            sectionsProp["description"] as? String == SECTIONS_LIST_V1
        )

        let items = sectionsProp["items"] as! [String: Any]
        #expect(items["type"] as? String == "object")
        #expect(items["additionalProperties"] as? Bool == false)

        let itemProps = items["properties"] as! [String: Any]
        #expect(itemProps["title"] as? [String: Any] != nil)
        #expect(itemProps["description"] as? [String: Any] != nil)
        #expect(itemProps["keywords"] as? [String: Any] != nil)

        let titleProp = itemProps["title"] as! [String: Any]
        #expect(titleProp["type"] as? String == "string")

        let required = schemaDict["required"] as! [String]
        #expect(required.contains("sections"))
    }
}
