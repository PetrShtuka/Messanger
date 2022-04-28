//
//  ValidationViewModel.swift
//  Messanger
//
//  Created by Peter on 25.04.2022.
//

import Foundation
import RxRelay

protocol ValidationViewModel {
    var errorMessage: String { get }
    // Observables
    var data: BehaviorRelay<String> { get set }
    var errorValue: BehaviorRelay<String?> { get}
    // Validation
    func validateCredentials() -> Bool
}
