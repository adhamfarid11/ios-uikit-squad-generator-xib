//
//  GeneratorInteractor.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

import Foundation

protocol GeneratorUseCase: AnyObject {
    func generateName() -> GeneratedName
}

final class GeneratorInteractor: GeneratorUseCase {
    private let data: NameParts
    private let predefinedProbability: Int // 0...100

    init(data: NameParts,
         predefinedProbability: Int = 10) {
        self.data = data
        self.predefinedProbability = predefinedProbability
    }

    func generateName() -> GeneratedName {
        let roll = Int.random(in: 1...100)
        if roll <= predefinedProbability, let fromPredefined = data.predefined.randomElement() {
            return GeneratedName(raw: fromPredefined)
        }
        if let f = data.firstNames.randomElement(),
           let l = data.lastNames.randomElement() {
            return GeneratedName(raw: "\(f) \(l)")
        }
        return GeneratedName(raw: "No name available")
    }
}
