rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // For development only - allow all operations if authenticated
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}