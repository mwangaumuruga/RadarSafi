# Google Gemini API Setup Guide

## Issue: 404 Error

If you're seeing a 404 error when using the LLM verification features, it means the Google Gemini API is not enabled for your API key.

## Steps to Fix:

### 1. Enable Gemini API in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Navigate to **APIs & Services** > **Library**
4. Search for "**Generative Language API**" or "**Gemini API**"
5. Click on it and press **Enable**

### 2. Verify API Key Permissions

1. Go to **APIs & Services** > **Credentials**
2. Find your API key
3. Click on it to edit
4. Under **API restrictions**, make sure:
   - Either "Don't restrict key" is selected, OR
   - "Restrict key" is selected and "Generative Language API" is included in the list

### 3. Check API Quotas

1. Go to **APIs & Services** > **Dashboard**
2. Find "Generative Language API"
3. Check if there are any quota limits that might be blocking requests

### 4. Test the API Key

You can test if your API key works by making a simple curl request:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSy************************" \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, test message"
      }]
    }]
  }'
```

⚠️ **Replace `AIzaSy************************` with your actual API key from Google Cloud Console.**

### 5. Alternative: Use Gemini 1.5 Flash (Recommended)

If you continue to have issues, you might want to try using `gemini-1.5-flash` model instead, which is more widely available:

Update the model name in the code from:
- `gemini-pro` → `gemini-1.5-flash`
- `gemini-pro-vision` → `gemini-1.5-flash` (for images)

## Current API Endpoints Used:

- **Text/Link/Phone Analysis**: `gemini-pro:generateContent`
- **Image Analysis**: `gemini-pro-vision:generateContent`
- **Chatbot**: `gemini-pro:generateContent`

## Note:

The API key you provided should have access to the Gemini API. If you're still getting 404 errors after enabling the API, please:
1. Wait a few minutes for the changes to propagate
2. Try regenerating the API key
3. Check if your Google Cloud billing is set up (some APIs require billing)

