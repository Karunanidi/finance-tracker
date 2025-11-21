# App Permissions Configuration

This document explains all the permissions configured for the Finance Tracker app and why they are needed.

## Android Permissions (AndroidManifest.xml)

### Internet & Network
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```
**Why needed**: To connect to Supabase backend for storing and retrieving transactions.

### Camera
```xml
<uses-permission android:name="android.permission.CAMERA" />
```
**Why needed**: To take photos of receipts directly from the app.

### Storage (Android 12 and below)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
```
**Why needed**: To read and save receipt images on devices running Android 12 or lower.

### Media Images (Android 13+)
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```
**Why needed**: Granular permission for accessing images on Android 13 and higher.

### Camera Features
```xml
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```
**Why needed**: Declares camera features but marks them as optional so the app can still be installed on devices without cameras.

---

## iOS Permissions (Info.plist)

### Camera Usage
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos of receipts for expense tracking.</string>
```
**Why needed**: iOS requires a description explaining why the app needs camera access. This message is shown to users when they first use the camera feature.

### Photo Library Access
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select receipt images for expense tracking.</string>
```
**Why needed**: To allow users to select existing photos from their library.

### Photo Library Add
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save receipt photos to your photo library.</string>
```
**Why needed**: To save captured receipt photos to the user's photo library.

---

## Permission Flow

### First Time Usage
1. **Camera**: When user taps "Take Photo" button, the OS will show a permission dialog
2. **Photo Library**: When user taps "Gallery" button, the OS will show a permission dialog
3. **Internet**: Automatically granted, no user prompt needed

### User Actions
- Users can **grant** or **deny** permissions
- If denied, the app will show an error message
- Users can change permissions later in device settings

### Graceful Degradation
- If camera permission is denied: User can still use gallery
- If photo library permission is denied: User can still use camera
- If both are denied: User can still manually enter transactions without receipts
- If internet is unavailable: App will show connection errors

---

## Testing Permissions

### Android
1. Install the app
2. Go to Settings → Apps → Finance Tracker → Permissions
3. Verify these permissions are listed:
   - Camera
   - Photos and videos (or Storage on older devices)

### iOS
1. Install the app
2. Go to Settings → Finance Tracker
3. Verify these permissions are listed:
   - Camera
   - Photos

---

## Security & Privacy

✅ **Minimal Permissions**: Only requests permissions that are actually needed
✅ **Optional Camera**: App works even on devices without cameras
✅ **User Control**: Users can revoke permissions at any time
✅ **Clear Descriptions**: Explains exactly why each permission is needed
✅ **No Background Access**: Permissions only used when app is active

---

## Troubleshooting

### "Permission Denied" errors
1. Check device settings and ensure permissions are granted
2. Uninstall and reinstall the app to reset permissions
3. On iOS, permissions can only be requested once - if denied, user must enable in Settings

### Camera not working
1. Verify camera permission is granted
2. Check if device has a working camera
3. Try restarting the app

### Gallery not working
1. Verify photo library permission is granted
2. Check if device has photos available
3. Try restarting the app
