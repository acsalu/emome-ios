if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No keys need to be added."
  exit 0
fi

if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No keys need to be added."
  exit 0
fi

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ./script/cert/developer.cer.enc -d -a -out ./script/cert/developer.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in ./script/cert/developer.p12.enc -d -a -out ./script/cert/developer.p12

security create-keychain -p travis ios-build.keychain
security import ./script/cert/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./script/cert/developer.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./script/cert/developer.p12 -k ~/Library/Keychains/ios-build.keychain -P $IOS_KEY_PASSWORD -T /usr/bin/codesign

echo "Unlock keychain"
security unlock-keychain -p secret ios-build.keychain

echo "Increase keychain unlock timeout"
security set-keychain-settings -lut 7200 ios-build.keychain

echo "Add keychain to keychain-list"
security list-keychains -s ios-build.keychain

echo "Add Provisioning Profiles"
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./script/profile/* ~/Library/MobileDevice/Provisioning\ Profiles/