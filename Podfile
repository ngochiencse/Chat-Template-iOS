# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def pods
  # Common
  pod 'SDWebImage'
  pod 'FLEX', :configurations => ['Debug']
  pod 'CocoaLumberjack/Swift'
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'RoundedUI'
  pod 'SnapKit', '~> 5.0.0'
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'RxCocoa'
  pod 'NSObject+Rx'
  pod 'RxBiBinding'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'SwiftDate', '~> 5.0'
  pod 'RSKGrowingTextView'
  pod 'Tatsi'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'SwiftLint'
end

target 'ChatTemplate' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatTemplate
  pods

  target 'ChatTemplateTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ChatTemplateUITests' do
    # Pods for testing
  end

end
