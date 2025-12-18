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
    struct Model: SmartCodableX {
        var name: String = ""
        var age: Int = 0
    }
    
    @Published var model: Model?
    
    private var disposeBag = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        $model
            .dropFirst()
            .sink { m in
                print("model 1 change = \((m, default: 999))")
            }
            .store(in: &disposeBag)
        
        self.publisher(for: \.model)
            .sink { m in
                print("model 2 change = \((m, default: 999))")
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

        guard var model else {
            return
        }
        
        SmartUpdater.update(&model, from: dic2)
        
        #expect(model.age == 200)
    }
}
