//
//  LegalLink.swift
//  131DrelrengilCrorforslar
//

import Foundation

enum LegalLink: String, CaseIterable {
    case privacyPolicy
    case termsOfUse

    var url: URL? {
        switch self {
        case .privacyPolicy:
            return URL(string: "https://drelrengil131crorforslar.site/privacy/81")
        case .termsOfUse:
            return URL(string: "https://drelrengil131crorforslar.site/terms/81")
        }
    }

    var titleKey: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of Use"
        }
    }
}
