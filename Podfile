# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def shared
  # Pods for PodTest
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.14.0'

  # (Recommended) Pod for Google Analytics
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
end

target 'Grade Converter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  shared
end

target 'Grade Converter Pro' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  shared
end

target 'Grade ConverterTests' do
  inherit! :search_paths
  # Pods for testing
  shared
end

target 'Grade ConverterUITests' do
  inherit! :search_paths
  # Pods for testing
  shared
end
