workspace 'BTCMarkets.xcworkspace'

use_frameworks!
platform :ios, '11.0'

target 'BTCMarkets' do
  pod 'PromiseKit'
  pod 'ObjectMapper'
  pod 'Socket.IO-Client-Swift', '~> 13.1.0'
  pod 'Mixpanel-swift'
  pod 'Charts'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'RxSwift'

  target 'BTCMarkets-Tests' do
    inherit! :search_paths  
    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        plist_buddy = "/usr/libexec/PlistBuddy"
        plist = "Pods/Target Support Files/#{target}/Info.plist"

        puts "Add armv7 to #{target} to make it pass iTC verification."

        `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities array" "#{plist}"`
        `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities:0 string armv7" "#{plist}"`
        `#{plist_buddy} -c "Add UIRequiredDeviceCapabilities:1 string arm64" "#{plist}"`
    end
end
