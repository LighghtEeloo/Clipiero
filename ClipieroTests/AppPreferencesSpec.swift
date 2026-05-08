import Foundation
import Quick
import Nimble
import RxSwift
@testable import Clipiero

class AppPreferencesSpec: QuickSpec {
    override class func spec() {
        describe("AppPreferences") {
            var suiteName: String!
            var defaults: UserDefaults!
            var preferences: AppPreferences!

            beforeEach {
                suiteName = "AppPreferencesSpec-\(UUID().uuidString)"
                defaults = UserDefaults(suiteName: suiteName)
                defaults.removePersistentDomain(forName: suiteName)
                preferences = AppPreferences(defaults: defaults)
            }

            afterEach {
                defaults.removePersistentDomain(forName: suiteName)
            }

            it("reads typed values from defaults") {
                defaults.set(12, forKey: Constants.UserDefaults.maxHistorySize)
                defaults.set(true, forKey: Constants.UserDefaults.showIconInTheMenu)
                defaults.set(false, forKey: Constants.UserDefaults.copySameHistory)
                defaults.set(7, forKey: Constants.Beta.pastePlainTextModifier)
                defaults.set(["String": NSNumber(value: false)], forKey: Constants.UserDefaults.storeTypes)

                expect(preferences.maxHistorySize) == 12
                expect(preferences.showIconInTheMenu) == true
                expect(preferences.copySameHistory) == false
                expect(preferences.pastePlainTextModifier) == 7
                expect(preferences.storeTypes["String"]?.boolValue) == false
            }

            it("emits store type changes") {
                var disposable: Disposable?
                waitUntil(timeout: .seconds(1)) { done in
                    disposable = preferences.storeTypesChanges
                        .take(1)
                        .subscribe(onNext: { storeTypes in
                            expect(storeTypes["String"]?.boolValue) == true
                            done()
                        })

                    defaults.set(["String": NSNumber(value: true)], forKey: Constants.UserDefaults.storeTypes)
                }
                disposable?.dispose()
            }

            it("emits menu changes for observed menu defaults") {
                defaults.set(false, forKey: Constants.UserDefaults.showImageInTheMenu)

                var disposable: Disposable?
                waitUntil(timeout: .seconds(1)) { done in
                    disposable = preferences.menuChanges
                        .take(1)
                        .subscribe(onNext: {
                            done()
                        })

                    defaults.set(true, forKey: Constants.UserDefaults.showImageInTheMenu)
                }
                disposable?.dispose()
            }
        }
    }
}
