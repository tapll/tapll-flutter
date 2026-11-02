#
# CocoaPods is NOT a supported install path on iOS: the Tapll iOS SDK is a Swift package only and has
# no CocoaPods spec. Use Flutter's Swift Package Manager integration (Flutter >= 3.24,
# `flutter config --enable-swift-package-manager`), which reads ios/tapll/Package.swift.
#
# This podspec exists so `flutter pub get` and projects that still run CocoaPods for other plugins can
# resolve the plugin. The Swift sources are the same files; without the Tapll module they stop at a
# compile-time error that says what to do, instead of building a plugin that silently does nothing.
#
Pod::Spec.new do |s|
  s.name             = 'tapll'
  s.version          = '0.2.0'
  s.summary          = 'Tapll analytics and crash reporting for Flutter.'
  s.description      = <<-DESC
A thin wrapper over the native Tapll iOS and Android SDKs. Requires Swift Package Manager on iOS.
                       DESC
  s.homepage         = 'https://tapll.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Tapll' => 'hello@tapll.com' }
  s.source           = { :path => '.' }
  s.source_files = 'tapll/Sources/tapll/**/*.swift', 'TapllCore/Sources/TapllCore/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
  s.resource_bundles = {'tapll_privacy' => ['tapll/Sources/tapll/PrivacyInfo.xcprivacy']}
end
