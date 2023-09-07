Pod::Spec.new do |spec|
    spec.name         = 'Userop'
    spec.version      = '0.0.1'
    spec.ios.deployment_target = "13.0"
    spec.osx.deployment_target = "12.0"
    spec.license      = { :type => 'MIT License', :file => 'LICENSE.md' }
    spec.summary      = 'swift version of https://github.com/stackup-wallet/userop.js'
    spec.homepage     = 'https://github.com/iotexproject/userop-swift'
    spec.author       = {}
    spec.source       = { :git => 'https://github.com/iotexproject/userop-swift.git', :tag => spec.version.to_s }
    spec.swift_version = '5.8'

    spec.source_files =  "Sources/userop-swift/**/*.swift"
    spec.frameworks = 'Foudation'

    spec.dependency 'Web3Core'
    spec.dependency 'web3swift'
end