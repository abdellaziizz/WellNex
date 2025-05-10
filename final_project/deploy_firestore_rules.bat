@echo off
echo Deploying Firestore rules to Firebase project wellnexapp-24d59

:: Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Firebase CLI not found. Installing...
    npm install -g firebase-tools
)

:: Log in to Firebase (if not already logged in)
firebase login

:: Deploy Firestore rules
firebase deploy --only firestore:rules --project wellnexapp-24d59

echo Deployment complete!
pause 