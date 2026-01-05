from flask import Flask, request, jsonify
from flask_cors import CORS
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

# Download the VADER lexicon (Dictionary of emotional intensity)
nltk.download('vader_lexicon')

app = Flask(__name__)
CORS(app)

# Initialize the ML Analyzer
analyzer = SentimentIntensityAnalyzer()

# --- Helper Function for Bot Persona (For Feature A: Chat) ---
def get_bot_persona_advice(score):
    if score <= -0.5:
        return "The user is in significant distress. Be extremely gentle, validate their pain, and keep your answer short."
    elif score < 0:
        return "The user seems a bit down. Be encouraging and supportive."
    else:
        return "The user seems stable. Engage in a friendly, helpful conversation."

@app.route('/')
def home():
    return "Renbo ML Brain is Active!"

# --- FEATURE A & B: Unified Sentiment Analysis ---
@app.route('/analyze', methods=['POST'])
def analyze_text():
    data = request.get_json()
    user_text = data.get('text', '')

    if not user_text:
        return jsonify({"status": "error", "message": "No text provided"}), 400

    # 1. ML Analysis Logic (VADER)
    scores = analyzer.polarity_scores(user_text)
    compound_score = scores['compound']

    # 2. Assign Risk Label
    if compound_score <= -0.5:
        risk_level = "High Risk - Please reach out"
    elif compound_score < 0:
        risk_level = "Moderate - Feeling down"
    else:
        risk_level = "Low - Stable"

    return jsonify({
        "status": "success",
        "sentiment_score": compound_score,
        "risk_level": risk_level,
        "persona_advice": get_bot_persona_advice(compound_score),
        "details": scores,
        "word_count": len(user_text.split())
    })

# --- FEATURE C: Holistic Wellness Analysis (Updated for Empathetic Feedback) ---
@app.route('/holistic_analysis', methods=['POST'])
def holistic_analysis():
    data = request.get_json()
    
    # average sentiment gathered from previous /analyze calls
    chat_sentiment = data.get('avg_sentiment', 0) 
    
    # usage stats tracked in Flutter/Firebase
    usage_data = data.get('usage_stats', {}) 
    
    # Internal math remains for logic branching
    internal_score = (chat_sentiment + 1) * 50 
    
    # Empathetic feedback logic based on internal score thresholds
    if internal_score < 40:
        feedback = "It looks like things have been a bit heavy lately. Remember that it's okay to move slowly. Small steps, like a deep breath or a short walk, are still progress."
        advice = "Would you like to try the 'Breathe' exercise in the Aftercare section?"
    elif internal_score < 70:
        feedback = "You're navigating through your days with steady effort. It's a good time to check in on your self-care routines."
        advice = "Perhaps a quick session in the 'Meditation' module could help maintain your balance."
    else:
        feedback = "You seem to be in a resilient headspace! It’s wonderful to see you engaging with the tools that support your peace."
        advice = "Since you're feeling stable, maybe try the 'Gratitude Bubbles' to capture this positive energy."

    # Return successful qualitative feedback without displaying numerical scores
    return jsonify({
        "status": "success",
        "feedback": feedback,
        "advice": advice,
        "internal_severity": "high" if internal_score < 40 else "normal" # Optional internal flag
    })

if __name__ == '__main__':
    # host='0.0.0.0' allows external connections from your Flutter app
    app.run(debug=True, host='0.0.0.0', port=5000)