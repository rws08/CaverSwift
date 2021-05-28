Pod::Spec.new do |s|
  s.name             = 'CaverSwift'
  s.version          = '0.0.1'
  s.summary          = 'CaverSwift'
 
  s.description      = 'CaverSwift desc'
 
  s.homepage         = 'https://github.com/rws08/CaverSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = ''
  s.source           = { :git => 'https://github.com/rws08/CaverSwift.git', :tag => s.version.to_s }
 
  s.swift_versions = '5.0'
  s.ios.deployment_target = '12.0'
  s.source_files = 'CaverSwift/**/*.swift', 'CaverSwift/lib/**/*.{c,h}'
  s.pod_target_xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]' => '$(PODS_TARGET_SRCROOT)/CaverSwift/lib/**',
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]' => '$(PODS_TARGET_SRCROOT)/CaverSwift/lib/**'
  }
  s.preserve_paths = 'CaverSwift/lib/**/module.map'
 
  s.dependency 'BigInt', '~> 5.0.0'
  s.dependency 'secp256k1.swift', '~> 0.1'
  s.dependency 'GenericJSON', '~> 2.0'
end
