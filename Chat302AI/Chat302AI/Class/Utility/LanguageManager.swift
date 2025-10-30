import Foundation
import SwiftUI
 


class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
        
        private let languageKey = "selectedLanguage"
        
        @Published var currentLanguage: String {
            didSet {
                UserDefaults.standard.set(currentLanguage, forKey: languageKey)
            }
        }
        
        // 当前语言的详细描述
        var currentLanguageDescription: String {
            let locale = Locale(identifier: currentLanguage)
            let languageName = locale.localizedString(forLanguageCode: currentLanguage)?.capitalized ?? currentLanguage
            //let nativeName = getNativeLanguageName(for: currentLanguage)
            
            //return "\(languageName) (\(nativeName)) [\(currentLanguage)]"
            return "\(languageName)"
        }
        
        private init() {
            if let savedLanguage = UserDefaults.standard.string(forKey: languageKey) {
                currentLanguage = savedLanguage
            } else {
                let systemLanguage = Locale.preferredLanguages.first ?? "en"
                let simplifiedLanguage = String(systemLanguage.prefix(2))
                currentLanguage = simplifiedLanguage
                UserDefaults.standard.set(currentLanguage, forKey: languageKey)
            }
        }
        
        func setLanguage(_ language: String) {
            currentLanguage = language
        }
        
        func availableLanguages() -> [String] {
            return ["en", "zh-Hans", "ja"]   //["en", "zh", "es", "fr", "de", "ja"]
        }
        
        func displayName(for languageCode: String) -> String {
            let locale = Locale(identifier: languageCode)
            return locale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode
        }
        
        private func getNativeLanguageName(for languageCode: String) -> String {
            let locale = Locale(identifier: languageCode)
            return locale.localizedString(forLanguageCode: languageCode)?.capitalized ?? languageCode
        }
}


extension String {
    func localized() -> String {
        let language = LanguageManager.shared.currentLanguage
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
    
    func localized(with args: CVarArg...) -> String {
        String(format: localized(), arguments: args)
    }
}

struct LanguagePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationView {
            List(languageManager.availableLanguages(), id: \.self) { languageCode in
                Button(action: {
                    languageManager.setLanguage(languageCode)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(languageManager.displayName(for: languageCode))
                        Spacer()
                        if languageCode == languageManager.currentLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("语言选择".localized())
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}
