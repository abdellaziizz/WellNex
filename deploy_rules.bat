@echo off
echo Deploying Firestore security rules...
firebase deploy --only firestore:rules

echo.
echo If the deployment succeeded, your Firestore rules are now updated.
echo If you see any errors, make sure you:
echo 1. Have the Firebase CLI installed (npm install -g firebase-tools)
echo 2. Are logged in to Firebase (firebase login)
echo 3. Have initialized Firebase in this project (firebase init)
echo.
pause 