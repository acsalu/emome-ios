if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No keys need to be added."
  exit 0
fi

if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No keys need to be added."
  exit 0
fi

openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in cert/developer.cer.enc -d -a -out cert/developer.cer
openssl aes-256-cbc -k "$ENCRYPTION_SECRET" -in cert/developer.cer.enc -d -a -out cert/developer.cer

security create-keychain -p travis ios-build.keychain
security import cert/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import cert/developer.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import cert/developer.p12 -k ~/Library/Keychains/ios-build.keychain -P $IOS_KEY_PASSWORD -T /usr/bin/codesign