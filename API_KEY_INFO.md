# Google API Key Type Confirmation

## API Key Format
Your API key format: `AIzaSyC3YlVw53bS6otPUC1C_pVRbnK5i1-7Uzc`

This is a **standard Google API key** that can be used for:
- Google Gemini API (Generative AI)
- Other Google Cloud services

## Authentication Methods

### Method 1: Header Authentication (Currently Implemented - Preferred)
```dart
headers: {
  'Content-Type': 'application/json',
  'x-goog-api-key': apiKey,
}
```

### Method 2: Query Parameter (Fallback)
```dart
Uri.parse('...?key=$apiKey')
```

## Models Used

### Text/Link/Phone Analysis
- **Model**: `gemini-1.5-flash`
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

### Image Analysis
- **Model**: `gemini-1.5-flash` (supports vision)
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

### Chatbot
- **Model**: `gemini-1.5-flash`
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

## Why gemini-1.5-flash?

1. **More widely available** - Better access than gemini-pro
2. **Supports vision** - Can analyze images without needing a separate vision model
3. **Faster responses** - Optimized for speed
4. **Free tier friendly** - Better quota availability

## API Key Requirements

Your API key needs:
1. ✅ **Generative Language API enabled** in Google Cloud Console
2. ✅ **Proper permissions** set in API key restrictions (if any)
3. ✅ **Billing enabled** (if using paid tier, though free tier may work)

## Testing the API Key

You can test if your API key works using curl:

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent" \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: YOUR_API_KEY" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, test message"
      }]
    }]
  }'
```

Replace `YOUR_API_KEY` with your actual key.

## Current Implementation

All services now use:
- ✅ Header authentication (`x-goog-api-key`)
- ✅ `gemini-1.5-flash` model
- ✅ Proper error handling
- ✅ Environment variable storage (`.env` file)

