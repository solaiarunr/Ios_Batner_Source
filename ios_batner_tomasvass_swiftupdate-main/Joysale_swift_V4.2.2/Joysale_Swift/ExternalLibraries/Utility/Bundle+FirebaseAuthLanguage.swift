//
//  Bundle+FirebaseAuthLanguage.swift
//  Joysale_Swift
//

import Foundation
import ObjectiveC
import FirebaseAuthUI
import FirebasePhoneAuthUI

private var firebaseLanguageBundleKey: UInt8 = 0

private final class FirebaseLocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let languageBundle = objc_getAssociatedObject(self, &firebaseLanguageBundleKey) as? Bundle {
            let localized = languageBundle.localizedString(forKey: key, value: nil, table: tableName)
            if !localized.isEmpty, localized != key {
                return localized
            }
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

enum FirebaseAuthLanguage {
    static func apply(languageCode: String, authUI: FUIAuth? = FUIAuth.defaultAuthUI()) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        let appLanguageBundle = appLanguageBundle(for: languageCode)
        let phoneResourceBundle = firebaseResourceBundle(named: "FirebasePhoneAuthUI", frameworkClass: FUIPhoneAuth.self)
        let authResourceBundle = firebaseResourceBundle(named: "FirebaseAuthUI", frameworkClass: FUIAuth.self)
        let bundles = [phoneResourceBundle, authResourceBundle]

        for bundle in bundles {
            if let appLanguageBundle = appLanguageBundle {
                attachLanguageBundle(appLanguageBundle, to: bundle)
            } else {
                forceLanguage(languageCode, on: bundle)
            }
        }

        if let authUI = authUI {
            authUI.customStringsBundle = appLanguageBundle
                ?? languageBundle(for: languageCode, in: phoneResourceBundle)
                ?? languageBundle(for: languageCode, in: authResourceBundle)
        }
    }

    private static func appLanguageBundle(for languageCode: String) -> Bundle? {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj", inDirectory: "FirebaseAuth") {
            return Bundle(path: path)
        }
        return nil
    }

    private static func firebaseResourceBundle(named name: String, frameworkClass: AnyClass) -> Bundle {
        let frameworkBundle = Bundle(for: frameworkClass)
        if let path = Bundle.main.path(forResource: name, ofType: "bundle")
            ?? frameworkBundle.path(forResource: name, ofType: "bundle"),
           let resourceBundle = Bundle(path: path) {
            return resourceBundle
        }
        return frameworkBundle
    }

    private static func languageBundle(for languageCode: String, in resourceBundle: Bundle) -> Bundle? {
        if let lprojPath = resourceBundle.path(forResource: languageCode, ofType: "lproj") {
            return Bundle(path: lprojPath)
        }
        return nil
    }

    private static func attachLanguageBundle(_ languageBundle: Bundle, to resourceBundle: Bundle) {
        object_setClass(resourceBundle, FirebaseLocalizedBundle.self)
        objc_setAssociatedObject(
            resourceBundle,
            &firebaseLanguageBundleKey,
            languageBundle,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private static func forceLanguage(_ languageCode: String, on resourceBundle: Bundle) {
        guard let languageBundle = languageBundle(for: languageCode, in: resourceBundle) else { return }
        attachLanguageBundle(languageBundle, to: resourceBundle)
    }
}
