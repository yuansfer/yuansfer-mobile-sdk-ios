Pod::Spec.new do |s|
  s.name         = 'Pockyt'
  s.version      = '0.5.2'
  s.summary      = 'Pockyt Mobile iOS SDK'
  s.description  = <<-DESC
                   A simple and user-friendly iOS payment SDK that supports payment methods such as WeChat Pay, Alipay, Braintree, and more.
                   DESC
  s.homepage     = 'https://pockyt.io'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Fly' => 'hanshan@pockyt.io' }
  s.platform     = :ios, '12.0'
  s.source       = { :git => 'https://github.com/yuansfer/yuansfer-mobile-sdk-ios.git', :tag => s.version }
  s.requires_arc = true
  s.default_subspecs = ['Core', 'Alipay', 'WechatPay']
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.swift_version = '5.0'
  s.static_framework = true
    
  s.subspec 'Core' do |ss|
    ss.source_files = 'Pockyt/Classes/Core/*.swift'
    ss.xcconfig = { 'SWIFT_VERSION' => '5.0' }
  end
    
  s.subspec 'Alipay' do |ss|
    ss.source_files = 'Pockyt/Classes/Alipay/**/*'
    ss.public_header_files = 'Pockyt/Classes/Alipay/**/*.h'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'AlipaySDK-iOS', '~> 15.8.11'
  end
    
  s.subspec 'WechatPay' do |ss|
    ss.source_files = 'Pockyt/Classes/WechatPay/**/*'
    ss.public_header_files = 'Pockyt/Classes/WechatPay/**/*.h'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'WechatOpenSDK-XCFramework', '~> 2.0.2'
  end
  
  s.subspec 'DropIn' do |ss|
    ss.source_files = 'Pockyt/Classes/DropIn/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'BraintreeDropIn', '~> 9.8.0'
  end
  
  s.subspec 'CardPal' do |ss|
    ss.source_files = 'Pockyt/Classes/CardPal/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'Braintree', '~> 5.26.0'
  end
  
  s.subspec 'ApplePay' do |ss|
    ss.source_files = 'Pockyt/Classes/ApplePay/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'Braintree/ApplePay', '~> 5.26.0'
  end
  
  s.subspec 'Venmo' do |ss|
    ss.source_files = 'Pockyt/Classes/Venmo/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'Braintree/Venmo', '~> 5.26.0'
  end
  
  s.subspec 'ThreeDSecure' do |ss|
    ss.source_files = 'Pockyt/Classes/ThreeDSecure/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'Braintree/ThreeDSecure', '~> 5.26.0'
  end
  
  s.subspec 'DataCollect' do |ss|
    ss.source_files = 'Pockyt/Classes/DataCollect/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'Braintree/PayPalDataCollector', '~> 5.26.0'
  end
  
  s.subspec 'CashApp' do |ss|
    ss.source_files = 'Pockyt/Classes/CashApp/*.swift'
    ss.dependency 'Pockyt/Core'
    ss.dependency 'CashAppPayKit', '~> 0.6.1'
  end
end

