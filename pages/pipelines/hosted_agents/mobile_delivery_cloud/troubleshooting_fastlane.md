# Troubleshooting fastlane

This guide provides troubleshooting steps for common [fastlane](https://docs.fastlane.tools/) issues when working with iOS development in Buildkite's [Mobile Delivery Cloud](/docs/pipelines/hosted-agents/mobile-delivery-cloud/getting-started).

## Enabling verbose mode

Fastlane is a wrapper tool that by default tends to produce vague error messages which can make troubleshooting challenging. Running fastlane in verbose mode will output additional information that can help with debugging. To enable the verbose mode, set the `--verbose`flag:

```bash
fastlane [lane] --verbose
```

## Examining the logs

For successful debugging, you'll need Fastlane or xcodebuild logs. To be able to examine the logs, upload them as a [build artifact](/docs/pipelines/configure/artifacts).

When examining the verbose logs, the actual errors will often be found around the parts where fastlane reports its simplified error messages. For code signing errors specifically, look for messages containing 'codesign', 'security', or 'provisioning profile' and be sure to check the raw xcodebuild output which can be found in `$HOME/Library/Logs/gym/*`.

For more information regarding code signing errors, see fastlane's code signing [troubleshooting documentation](https://docs.fastlane.tools/codesigning/troubleshooting/).

## Common Fastlane errors and resolutions

The following section covers the errors you are most likely to encounter when using fastlane with Buildkite and ways to troubleshoot those errors.

### CocoaPods sandbox error

**Error message:**

```
The sandbox is not in sync with the Podfile.lock.
Run 'pod install' or update your CocoaPods installation.
```

The sandbox is the `Pods` directory within the project folder, representing the currently installed dependencies (pods). This error occurs when the installed dependencies don't match the pods and versions specified in the `Podfile.lock`.

**Resolution:**

To resolve the error, delete the current `Pods` directory and rebuild the sandbox from scratch based on the `Podfile.lock` by adding `cocoapods(clean: true)` to the `Fastfile`:

```ruby
lane :build do
  # This will delete and rebuild the entire Pods directory
  cocoapods(clean: true)

  # Rest of your lane...
end
```

If the proposed solution doesn't resolve the issue, ensure a consistent environment:

- Run `bundle install` before calling Fastlane to ensure all Ruby gems (since CocoaPods is a Ruby gem, too) are installed based on the `Gemfile.lock`
- Execute Fastlane using `bundle exec fastlane` to use the versions of gems specified in the `Gemfile.lock`

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

macOS hosted Buildkite agents have Ruby 3.4+ installed via Homebrew. In Ruby 3.4+, the gems `mutex_m` and `abbrev` are no longer the default gems. In Ruby 3.5+, `ostruct` will no longer be a default gem, causing Fastlane to fail.

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

- **Certificate and private keys:**
  * Certificate issued by Apple to verify the developer's identity
  * Private key available in the keychain
  * Both must be properly imported into a keychain
- **Provisioning profile:**
  * A `.mobileprovision` file installed in `~/Library/MobileDevice/Provisioning Profiles/`
  * Must match the app's bundle identifier
  * Must include the certificate being used to sign
  * Must contain the app's entitlements (push notification support, etc.)
  * Must not be expired
- **Keychain access:**
  * Keychain needs to be unlocked during the build
  * Should not be the default `login.keychain-db`
- **Xcode build settings:**
  * **Signing identity** - The certificate from the keychain
  * **Provisioning profile** - Valid `.mobileprovision` file that matches the app bundle ID
  * **Matching team ID** - Apple Developer Team ID must match between certificate and profile

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

> 📘 Fastlane match
> If you're using the [fastlane match](https://docs.fastlane.tools/actions/match/) implementation, many of the code signing steps will be automated. Match handles everything from creating and storing certificates and profiles, setting up code signing on a new machine, and handling multiple teams keys and profiles through Git. If match is being used, look for issues in the Matchfile and check the fastlane output logs.

### Troubleshooting steps

1. **Check certificate availability:**

    ```bash
    security find-identity -v -p codesigning
    ```

    If there are no valid identities, the certificates were imported incorrectly.

1. **Check the keychain:**

    ```bash
    security list-keychains
    ```

1. **Verify the provisioning profiles:**

    ```bash
    ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
    ```

1. **Run Fastlane with verbose logging:**

    ```bash
    bundle exec fastlane [lane_name] --verbose
    ```

## Keychain best practices

It's a best practice to create a new keychain for each build and import the certificates and profiles at build time. It is not recommended to use the default `login.keychain-db` in CI/CD environments. Remember to destroy this keychain at the end of the build for security.

Here's an example keychain setup script:

```bash
# Set up the keychain
echo "+++ Setting up keychain"
security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain

echo "Created Keychain"
security default-keychain -s build.keychain

echo "Set Keychain as Default"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain

echo "Unlocked Keychain"
security set-keychain-settings -t 3600 -u build.keychain

echo "Set Keychain Settings"
security list-keychains -d user -s build.keychain $(security list-keychains -d user | sed 's/"//g')
echo "Added Keychain to search list (required)"

# Import the certificate and give it codesign permission
echo "+++ Importing certificate"
security import "$CERT_PATH" -k build.keychain -P "$KEYCHAIN_PASSWORD" -T /usr/bin/codesign

echo "Imported certificate"
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" build.keychain
echo "Set Keychain partition List (Required)"

# At the end of the build
security delete-keychain build.keychain
```
