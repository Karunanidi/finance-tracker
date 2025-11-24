# AI Spending Recommendation Feature

This app includes an AI-powered spending recommendation feature that helps users maintain financial health by suggesting a "safe zone" daily spending limit.

## Features

- **AI-Powered Analysis**: Uses Google's Gemini AI to analyze spending patterns
- **Smart Recommendations**: Calculates personalized daily spending limits
- **Financial Health Status**: Visual indicators (healthy/warning/critical)
- **Rule-Based Fallback**: Works even without API key using intelligent algorithms

## Setup

### Option 1: With Gemini AI (Recommended)

1. Get a free Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

2. Run the app with the API key:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
   ```

3. For development, you can also set it in your IDE:
   - **VS Code**: Add to `.vscode/launch.json`:
     ```json
     {
       "configurations": [
         {
           "name": "Flutter",
           "request": "launch",
           "type": "dart",
           "args": ["--dart-define=GEMINI_API_KEY=your_api_key_here"]
         }
       ]
     }
     ```
   
   - **Android Studio**: Run → Edit Configurations → Additional run args:
     ```
     --dart-define=GEMINI_API_KEY=your_api_key_here
     ```

### Option 2: Without API Key

The app will automatically fall back to a rule-based recommendation system that:
- Recommends saving 20% of monthly income
- Calculates safe daily spending based on remaining days
- Provides health status based on spending rate

## How It Works

The AI analyzes:
- Monthly income and expenses
- Category-wise spending breakdown
- Days remaining in the month
- Current balance

Then provides:
- Daily spending limit to stay in the "safe zone"
- Personalized financial advice
- Health status indicator

## Privacy

- All AI processing happens via secure API calls
- No financial data is stored by the AI service
- Fallback mode works completely offline
