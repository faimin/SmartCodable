//
//  ModelUpdaterTest.swift
//  SmartCodable
//
//  Created by Zero.D.Saber on 2025/12/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SmartCodable
import Testing
import Combine

class ModelUpdaterTest: NSObject {
    class Model: ObservableObject, SmartCodableX {
        @SmartPublished var name: String = ""
        @SmartPublished var age: Int = 0
        
        required init() { }
    }
    
    @Published var model: Model?
    
    private var disposeBag = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        // ✅
        $model
            .filter { $0 != nil }
            .removeDuplicates(by: { $0?.age == $1?.age })
            .sink { m in
                print(">>>>> model 1 change = \(m?.age ?? -1)")
            }
            .store(in: &disposeBag)
        
        // ❌
        model?.$age
            .filter({ $0 != 0 })
            .removeDuplicates()
            .sink { x in
                print(">>>>>> x = \(x)")
            }
            .store(in: &disposeBag)
        
        // ✅
        $model
            .compactMap({ $0?.age })
            .filter({ $0 != 0 })
            .removeDuplicates()
            .sink { y in
                print(">>>>>> y = \(y)")
            }
            .store(in: &disposeBag)
    }
    
    @Test("model update with combine test")
    func updateAndCombine() {
        let dic1: [String : Any] = [
            "name": "mccc",
            "age": 10
        ]
        let dic2: [String : Any] = [
            "age": 200
        ]
        
        model = Model.deserialize(from: dic1)
        let p1 = withUnsafePointer(to: &(model!)) { $0 }
        
        SmartUpdater.update(&(model!), from: dic2)
        let p2 = withUnsafePointer(to: &(model!)) { $0 }
        
        print(">>>>>> p1 = \(p1), p2 = \(p2)")
        
        #expect(model?.age == 200)
        
        model!.objectWillChange
            .sink { [unowned self] _ in
                print("对象属性即将发生变更")
                #expect(model?.age == 200)
            }
            .store(in: &disposeBag)
        
        model?.age = 123
    }
}
