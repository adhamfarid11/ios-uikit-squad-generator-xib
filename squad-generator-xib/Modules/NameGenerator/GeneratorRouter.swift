//
//  GeneratorRouter.swift
//  squad-generator
//
//  Created by Adham Farid on 04/10/25.
//

// Generator/Router/GeneratorRouter.swift
import UIKit

protocol GeneratorRouting: AnyObject {
    // add navigation methods here (e.g., to a detail screen)
}

final class GeneratorRouter: GeneratorRouting { }

enum GeneratorModule {
    static func build() -> UIViewController {
        
        let data = NameParts(
            firstNames: [
                "Adham","Ade","Agus","Anggit","Arba","Ardyan","Aventdo","Davina","Dian",
                "Farhan","Fikri","Levi","Ziddan","Widya","Mora","Rimba","Rival","Salman",
                "Imam","Deru","Reggya","Arif","Darwin","Vera"
            ],
            lastNames: [
                "Farid","Susanto","Puji","Elbarca","Atmojo","Raynaldy","Alyssa","Putri",
                "Fatur","Zakka","Susantio","Dayat","Hakim","Simamora"
            ],
            predefined: ["Ade adean", "Mora Simamora"]
        )

        let interactor = GeneratorInteractor(data: data, predefinedProbability: 10)
        let router = GeneratorRouter()
        let view = ViewController()
        let presenter = GeneratorPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter       
        return view
    }
}
