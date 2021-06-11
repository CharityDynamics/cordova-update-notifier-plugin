/**
 * Copyright 2020 Ayogo Health Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import Siren_embed


@objc(CDVUpdateNotifierPlugin)
class UpdateNotifierPlugin : CDVPlugin {

    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(UpdateNotifierPlugin._didFinishLaunchingWithOptions(_:)),
                name: UIApplication.didFinishLaunchingNotification,
                object: nil);
    }


    @objc internal func _didFinishLaunchingWithOptions(_ notification : NSNotification) {
        // Check if there's an MDM setting to disable update checking
        let disableUpdateCheck = UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")?["DisableUpdateCheck"] as? String
        if (disableUpdateCheck == "true") {
            return;
        }

        let siren = Siren.shared

        // ~~~
        func setManager(values: Constants) -> PresentationManager {
            return PresentationManager(
                alertTintColor: nil,
                appName: nil,
                alertTitle: values.alertTitle,
                alertMessage: values.alertMessage,
                updateButtonTitle: values.updateButtonTitle,
                nextTimeButtonTitle: values.nextTimeButtonTitle,
                skipButtonTitle: values.skipButtonTitle,
                forceLanguageLocalization: nil)
        }

        siren.presentationManager = setManager(values: {(lang: String) in
            switch lang {
            case _ where lang.contains("es"): return Spanish()
            case _ where lang.contains("fr"): return French()
            default: return English()
            }
        }(Bundle.main.preferredLocalizations.first ?? "en"))
        // ~~~

        if let alertType = self.commandDelegate.settings["sirenalerttype"] as? String {
            switch alertType {
            case "critical":
                siren.rulesManager = RulesManager(globalRules: .critical)
                break;
            case "annoying":
                siren.rulesManager = RulesManager(globalRules: .annoying)
                break;
            default:
                siren.rulesManager = RulesManager(globalRules: .default)
            }
        }

        if let countryCode = self.commandDelegate.settings["sirencountrycode"] as? String {
            siren.apiManager = APIManager(countryCode: countryCode)
        }

        siren.wail()
    }
}


protocol Constants {
    var alertTitle: String {get}
    var alertMessage: String {get}
    var nextTimeButtonTitle: String {get}
    var skipButtonTitle: String {get}
    var updateButtonTitle: String {get}
}

struct English: Constants {
    let alertTitle = "Update Available"
    let alertMessage = "A new version of %@ is available. Please update to version %@ now"
    let nextTimeButtonTitle = "Next time"
    let skipButtonTitle = "Skip this version"
    let updateButtonTitle = "Update"
}

struct Spanish: Constants {
    let alertTitle = "Actualización disponible"
    let alertMessage = "Hay disponible una nueva versión de %@. Actualice a la versión %@ ahora"
    let nextTimeButtonTitle = "La próxima vez"
    let skipButtonTitle = "Omitir esta version"
    let updateButtonTitle = "Actualizar"
}

struct French: Constants {
    let alertTitle = "Mise à jour disponible"
    let alertMessage = "Une nouvelle version de %@ est disponible. Veuillez mettre à jour vers la version %@ maintenant"
    let nextTimeButtonTitle = "La prochaine fois"
    let skipButtonTitle = "Passez cette version"
    let updateButtonTitle = "Mettre à jour"
}