# Google API Setup Instructions

## Step 1: Create .env file

Create a `.env` file in the root directory of the project with the following content:

```
# Google API Configuration
GOOGLE_API_KEY=YOUR_API_KEY_HERE
```

**Important:** Make sure the `.env` file is in the root directory (same level as `pubspec.yaml`).

## Step 2: Verify the setup

1. The `.env` file is already configured in `pubspec.yaml` under assets
2. The API key is loaded automatically when the app starts (see `lib/main.dart`)
3. The verification service uses the API key from the environment

## How it works

- When a user submits an email/message for verification in the Report screen:
  1. The app calls `VerificationService.verifyEmailMessage()`
  2. The service analyzes the message content for scam indicators
  3. It checks the sender's domain reputation
  4. Returns verification results with agent response, report count, and advice

## Features

- ✅ No hardcoded API keys
- ✅ Environment-based configuration
- ✅ Scam detection using multiple indicators:
  - Common scam phrases
  - Suspicious URLs
  - Excessive urgency
  - Poor grammar/spelling
  - Requests for personal information
- ✅ Domain reputation checking
- ✅ Dynamic agent responses
- ✅ Report count tracking

## Testing

To test the verification:
1. Navigate to Report screen
2. Select "Email/Message" from the dropdown
3. Enter sender email and message content
4. Click "Submit"
5. View the verification results

