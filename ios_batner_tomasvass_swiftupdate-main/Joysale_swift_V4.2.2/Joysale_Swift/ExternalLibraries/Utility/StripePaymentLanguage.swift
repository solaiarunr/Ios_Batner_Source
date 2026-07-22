//
//  StripePaymentLanguage.swift
//  Joysale_Swift
//

import Foundation
import ObjectiveC
import Stripe

private var stripeLanguageBundleKey: UInt8 = 0

private final class StripeLocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let languageBundle = objc_getAssociatedObject(self, &stripeLanguageBundleKey) as? Bundle {
            let localized = languageBundle.localizedString(forKey: key, value: nil, table: tableName)
            if !localized.isEmpty, localized != key {
                return localized
            }
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

enum StripePaymentLanguage {
    static func apply(languageCode: String = DEFAULT_LANGUAGE_CODE) {
        let stripeLocale = localeIdentifier(for: languageCode)
        UserDefaults.standard.set([stripeLocale], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        let frameworkBundle = Bundle(for: PaymentSheet.self)
        for bundleName in ["Stripe", "StripeUICore", "StripeCore", "Stripe3DS2"] {
            let resourceBundle = resourceBundle(named: bundleName, frameworkBundle: frameworkBundle)
            forceLanguage(stripeLocale, on: resourceBundle)
        }
    }

    static func localeIdentifier(for languageCode: String) -> String {
        switch languageCode {
        case "cs":
            return "cs-CZ"
        case "sk":
            return "sk-SK"
        case "pl":
            return "pl-PL"
        default:
            return languageCode
        }
    }

    private static func resourceBundle(named name: String, frameworkBundle: Bundle) -> Bundle {
        if let path = Bundle.main.path(forResource: name, ofType: "bundle")
            ?? frameworkBundle.path(forResource: name, ofType: "bundle"),
           let resourceBundle = Bundle(path: path) {
            return resourceBundle
        }
        return frameworkBundle
    }

    private static func languageBundle(for languageCode: String, in resourceBundle: Bundle) -> Bundle? {
        let candidates = [
            resourceBundle.path(forResource: languageCode, ofType: "lproj"),
            resourceBundle.path(forResource: languageCode, ofType: "lproj", inDirectory: "Localizations")
        ]
        for path in candidates {
            if let path = path, let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return nil
    }

    private static func forceLanguage(_ languageCode: String, on resourceBundle: Bundle) {
        guard let languageBundle = languageBundle(for: languageCode, in: resourceBundle) else { return }
        object_setClass(resourceBundle, StripeLocalizedBundle.self)
        objc_setAssociatedObject(
            resourceBundle,
            &stripeLanguageBundleKey,
            languageBundle,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
