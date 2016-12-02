source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

use_frameworks!

target 'FLYR' do
    pod 'Cartography', '0.7.0'
    pod 'GGNLocationPicker', '1.0.0'
    pod 'GGNObservable', '~> 1.0'
end

def testing_pods
    pod 'Quick', '0.9.3'
    pod 'Nimble', '4.1.0'
end

target 'FLYRTests' do
    testing_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
  end
