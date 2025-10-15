//
//  DesignatedPathTest.swift
//  SmartCodable
//
//  Created by Zero.D.Saber on 2025/10/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SmartCodable
import Testing

struct DesignatedPathTest {
    struct Home: SmartCodable {
        @SmartAny
        var arr1: [Any]?
        var id: String?
        var arr2: [String]?
    }
    
    struct Family: SmartCodable {
        var name: String?
        var id: String?
        var height: Int?
    }
    
    struct PathModel: SmartCodable {
        var name: String?
        var age: Int?
    }
    
    struct NestedArrayModel: SmartCodable {
        var name: String?
        var friends: [Friend]?
        
        struct Friend: SmartCodable {
            var name: String = ""
            var age: Int = 0
        }
    }
    
    struct PathArrayModel: SmartCodable {
        var name: [String]?
    }
    
    struct Course: SmartCodable {
        var code: String?
        var title: String?
    }
    
    struct Department: SmartCodable {
        var name: String?
        var courses: [Course]?
    }
    
    struct School: SmartCodable {
        var name: String?
        var departments: [Department]?
    }
}

extension DesignatedPathTest {
    @Test
    func dataResult() {
        let jsonString = """
        {
            "data": {
                "result": {
                    "id":123456,
                    "arr1":[1,2,3,4,5,6],
                    "arr2":["a","b","c","d","e"]
                }
            },
            "code":200
        }
        """
        
        let data = jsonString.data(using: .utf8)
        let model = Home.deserialize(from: data, designatedPath: "data.result")
        #expect(model?.id == "123456")
    }
    
    @Test
    func jsonArray() {
        let jsonArrayString: String? = "{\"result\":{\"data\":[{\"name\":\"Bob\",\"id\":\"1\",\"height\":180},{\"name\":\"Lily\",\"id\":\"2\",\"height\":150},{\"name\":\"Lucy\",\"id\":\"3\",\"height\":160}]}}"

        let data = jsonArrayString?.data(using: .utf8)

        let models = [Family].deserialize(from: data, designatedPath: "result.data")
        #expect(models?.isEmpty == false)
    }
    
    @Test
    func testDeserializeArrayPath() {
        let jsonString = """
            {
                "people": [
                    {
                        "name": "John Doe",
                        "age": 30
                    },
                    {
                        "name": "Jane Smith",
                        "age": 25
                    }
                ]
            }
            """
        
        let models = [PathModel].deserialize(from: jsonString, designatedPath: "people")
        #expect(models?.count == 2)
    }
    
    @Test
    func testDeserializeNestedArrayPath() {
        let jsonString = """
            {
                "person": {
                    "name": "John Doe",
                    "friends": [
                        {
                            "name": "Alice",
                            "age": 25
                        },
                        {
                            "name": "Bob",
                            "age": 28
                        }
                    ]
                }
            }
            """
        
        let model = NestedArrayModel.deserialize(from: jsonString, designatedPath: "person")
        #expect(model?.friends?.isEmpty == false)
    }
    
    @Test
    func testDeserializeInvalidPath() {
        let jsonString = """
            {
                "person": {
                    "name": "John Doe",
                    "age": 30
                }
            }
            """
        
        let model = PathModel.deserialize(from: jsonString, designatedPath: "invalid.path")
        #expect(model == nil)
    }
    
    @Test
    func testDeserializeEmptyPath() {
        let jsonString = """
            {
                "name": "John Doe",
                "age": 30
            }
            """
        
        let model = PathModel.deserialize(from: jsonString, designatedPath: "")
        #expect(model?.age == 30)
    }
    
    @Test
    func testDeserializeArrayWithPath() {
        let jsonString = """
            {
                "data": {
                    "names": ["Alice", "Bob", "Charlie"]
                }
            }
            """
        
        let models = [PathArrayModel].deserialize(from: jsonString, designatedPath: "data.names")
        #expect(models?.isEmpty == false)
    }
    
    @Test
    func testDeserializeNestedStructure() {
        let jsonString = """
            {
              "code": 200,
              "message": "Success",
              "data": {
                "school": {
                  "name": "ABC University",
                  "departments": [
                    {
                      "name": "Computer Science",
                      "courses": [
                        {
                          "code": "CS101",
                          "title": "Introduction to Computer Science"
                        },
                        {
                          "code": "CS201",
                          "title": "Data Structures and Algorithms"
                        }
                      ]
                    },
                    {
                      "name": "Mathematics",
                      "courses": [
                        {
                          "code": "MATH101",
                          "title": "Calculus I"
                        },
                        {
                          "code": "MATH201",
                          "title": "Linear Algebra"
                        }
                      ]
                    }
                  ]
                }
              }
            }
            """
        
        let school = School.deserialize(from: jsonString, designatedPath: "data.school")
        #expect(school != nil)
        
        let departments = [Department].deserialize(from: jsonString, designatedPath: "data.school.departments")
        #expect(departments?.isEmpty == false)
    }
}
