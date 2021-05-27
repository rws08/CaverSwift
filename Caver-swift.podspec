Pod::Spec.new do |s|
  s.name             = 'Caver-swift'
  s.version          = '0.0.1'
  s.summary          = 'Caver-swift'
 
  s.description      = 'desc'
 
  s.homepage         = 'https://github.com/rws08/caver-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = ''
  s.source           = { :git => 'https://github.com/rws08/caver-swift.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '12.0'
  s.source_files = 'Caver-swift/*.swift'
 
end
