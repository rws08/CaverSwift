# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'CaverSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CaverSwift
#  pod 'web3.swift'
  pod 'BigInt'
  pod 'GenericJSON'
  pod 'secp256k1.swift'

  target 'CaverSwiftTests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
