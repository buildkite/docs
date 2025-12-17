# Troubleshooting fastlane

This guide is for troubleshooting some common [fastlane](https://fastlane.tools/) issues in iOS development, specifically when [using Buildkite Pipelines to build iOS apps](/docs/pipelines/hosted-agents/macos/getting-started-with-ios).

## Essential debugging steps

When fastlane fails, start with these troubleshooting steps:

1. Enable verbose logging for detailed error information:

    ```bash
    fastlane [lane] --verbose
    ```

1. Upload fastlane logs as build artifacts for analysis:
    * Configure the [build artifacts](/docs/pipelines/configure/artifacts) in your pipeline to upload your fastlane or xcodebuild logs.
    * Look for actual errors around fastlane's simplified error messages. When examining the verbose logs, you will often find the actual errors around the parts where fastlane reports its simplified error messages. For code signing errors specifically, look for messages containing "codesign", "security", or "provisioning profile".
    * For code signing issues, check `$HOME/Library/Logs/gym/*`. Learn more about fastlane's code signing errors in fastlane's documentation on [Debugging codesigning issues](https://docs.fastlane.tools/codesigning/troubleshooting/).

1. Verify your environment with these diagnostic commands:

    ```bash
    # Check code signing certificates
    security find-identity -v -p codesigning

    # Verify keychain configuration
    security list-keychains

    # List provisioning profiles
    ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
    ```

## Errors and resolutions for fastlane

This section covers some of the fastlane errors you may encounter when using Buildkite Pipelines to build iOS apps, and ways to troubleshoot those errors.

### CocoaPods sandbox error

**Error message:**

```
The sandbox is not in sync with the Podfile.lock.
Run 'pod install' or update your CocoaPods installation.
```

The sandbox is the `Pods` directory that contains your project's installed dependencies (pods). This error occurs when the installed dependencies don't match the pods and versions specified in the `Podfile.lock` file. It is best practice _not_ to commit the `Pods` directory to your repository, but only commit the `Podfile` and `Podfile.lock` files, and rebuild the dependencies during CI builds.

**Resolution:**

To resolve the error, run a standard Pod installation command:

```ruby
lane :build do
  # This will run pod install
  cocoapods()

  # Rest of your lane...
end
```

If this doesn't resolve the issue, try rebuilding the entire `Pods` directory:

```ruby
lane :build do
  # This will delete and rebuild your entire Pods directory
  cocoapods(clean_install: true)

  # Rest of your lane...
end
```

If both of these solutions still don't resolve the issue, ensure a consistent environment:

- Run `bundle install` before calling fastlane to ensure all Ruby gems are installed based on the `Gemfile.lock`, since CocoaPods is also a Ruby gem.
- Execute fastlane using `bundle exec fastlane` to use the versions of gems specified in the `Gemfile.lock`.

### Ruby gem dependency error

**Error message:**

```
bundler: failed to load command: fastlane (/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane)

/opt/homebrew/lib/ruby/gems/3.4.0/gems/fastlane-2.187.0/fastlane/lib/fastlane/cli_tools_distributor.rb:125:in 'Fastlane::CLIToolsDistributor.take_off': uninitialized constant FastlaneCore::UpdateChecker (NameError)

[⠋] 🚀 /opt/homebrew/lib/ruby/gems/3.4.0/gems/httpclient-2.8.3/lib/httpclient/auth.rb:11: warning: mutex_m was loaded from the standard library, but is not part of the default gems starting from Ruby 3.4.0.

You can add mutex_m to your Gemfile or gemspec to silence this warning.

/opt/homebrew/lib/ruby/gems/3.4.0/gems/json-2.2.0/lib/json/generic_object.rb:2: warning: ostruct was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.5.0.

You can add ostruct to your Gemfile or gemspec to silence this warning.

[⠙] 🚀 /opt/homebrew/lib/ruby/gems/3.4.0/gems/highline-2.0.3/lib/highline.rb:17: warning: abbrev was loaded from the standard library, but is not part of the default gems starting from Ruby 3.4.0.

You can add abbrev to your Gemfile or gemspec to silence this warning.
```

**Resolution:**

Buildkite Agents hosted on macOS have Ruby 3.4+ installed via Homebrew. In Ruby 3.4+, the gems `mutex_m` and `abbrev` are no longer the default gems. In Ruby 3.5+, `ostruct` will no longer be a default gem, causing fastlane to fail.

To fix this discrepancy, you need to add the following gems to the `Gemfile`:

```ruby
gem 'mutex_m'
gem 'ostruct'
gem 'abbrev'
```

### Code signing failure

**Error message:**

```
The following build commands failed:

CodeSign /Users/agent/buildkite/builds/...

Exit status: 65
```

This error occurs during the code signing process. Code signing requires several components to be set up correctly:

- Certificate and private keys:
   * Certificate issued by Apple to verify the developer's identity.
   * Private key available in the keychain.
   * Both must be properly imported into a keychain.

- Provisioning profile:
   * A `.mobileprovision` file installed in `~/Library/MobileDevice/Provisioning Profiles/`
   * Must match the app's bundle identifier.
   * Must include the certificate being used to sign.
   * Must contain the app's entitlements (for example, push notification support).
   * Must not be expired.

- Keychain access:
   * Keychain needs to be unlocked during the build.
   * Keychain should not be the default `login.keychain-db`.

- Xcode build settings:
   * **Signing identity**: The certificate from the keychain.
   * **Provisioning profile**: Valid `.mobileprovision` file that matches the app bundle ID.
   * **Matching team ID**: Apple Developer Team ID must match between certificate and profile.

Example Fastfile build configuration:

```ruby
build_app(
  scheme: "AppName",
  workspace: "AppName.xcworkspace",

  # Code signing configuration
  export_method: "app-store",
  export_options: {
    provisioningProfiles: {
      "com.company.appname" => "AppName Distribution Profile"
    },
    teamID: "ABCD12345E"
  },
  codesigning_identity: "iPhone Distribution: Company Name (ABCD12345E)"
)
```

## Using fastlane match

The fastlane platform offers the [match](https://docs.fastlane.tools/actions/match/) tool, which handles tasks ranging from creating and storing certificates and profiles, setting up code signing on a new machine, and handling multiple teams' keys and profiles through Git.

If you're using fastlane match, most code signing is automated:

```ruby
lane :build do
  # Match handles certificates and profiles automatically
  match(type: "appstore")
  
  build_app(
    scheme: "AppName",
    workspace: "AppName.xcworkspace"
  )
end
```

If you're experiencing issues with fastlane match, look for issues in the Matchfile and check the fastlane output logs. For troubleshooting match:

- Verify your `Matchfile` configuration.
- Check match repository access permissions.
- Review match output logs for specific errors.
