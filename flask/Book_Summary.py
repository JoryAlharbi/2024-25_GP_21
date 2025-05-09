############ thread summary 

from transformers import pipeline
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask import Blueprint
from transformers import pipeline


#Summarization model
BookSum_bp = Blueprint('BookSum_bp', __name__)

summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

@BookSum_bp.route('/summarize', methods=['POST'])
def summarize():
    data = request.json
    text = data.get("text", "")

    if not text:
        return jsonify({"error": "No text provided"}), 400

    try:
        # Generate the summary using Hugging Face
        summary = summarizer(text, max_length=130, min_length=30, do_sample=False)

        return jsonify({"summary": summary[0]['summary_text']})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

