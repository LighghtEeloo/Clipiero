# Contributing to Clipiero

:tada: Thank you for contributing to Clipiero :tada:

## Localization

### Add New Language
<img src="../Resources/new_localization.png" width="600">

After adding the language, please make changes to the various `.strings` files as follows.

### Modify an Existing Language
The files to be localized are as follows.
- Localizable.strings ( `Clipiero/Resources/#{language_name}.lproj/Localizable.strings` )
- Preferences ( `Clipiero/Sources/Preferences/#{language_name}.lproj/*.strings` )
- PreferencesPanels ( `Clipiero/Sources/Preferences/Panels/#{language_name}.lproj/*.strings` )
- SnippetsEditor ( `Clipiero/Sources/Snippets/#{language_name}.lproj/*.strings` )

**English localization only, please edit `.xib` files directly**
