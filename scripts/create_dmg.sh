echo "Creating dmg..."

cd ..
create-dmg \
  --volname "Cloud" \
  --window-size 500 300 \
  --icon Cloud.app 130 110 \
  --app-drop-link 360 110 \
  Cloud.dmg \
  build/macos/Build/Products/Release/Cloud.app
echo "Let's go!!!!!!"