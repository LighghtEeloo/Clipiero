# Apply SwiftLint
if system("command -v swiftlint >/dev/null")
  swiftlint.config_file = '.swiftlint.yml'
  swiftlint.binary_path = "swiftlint"
  swiftlint.lint_files inline_mode: true
else
  warn("SwiftLint is not installed; skipping SwiftLint.")
end
