source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

use_frameworks!

def shared_pods
    pod 'GGNObservable', '~> 2.0'
end

target 'FLYR' do
    shared_pods
    pod 'Cartography', '~> 1.0'
    pod 'GGNLocationPicker', '~> 2.0'
end

target 'FLYRTests' do
    shared_pods
    pod 'Quick', '~> 1.0'
    pod 'Nimble', '~> 5.0'
end
