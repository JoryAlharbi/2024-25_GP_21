# Import necessary libraries
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask import Blueprint
from transformers import pipeline


#book desctiption generation 
description_bp = Blueprint('description_bp', __name__)  # Blueprint name
summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

@description_bp.route('/generate_description', methods=['POST'])
def generate_description():
    data = request.json
    book_parts = data.get("parts", [])

    if not book_parts:
        return jsonify({"error": "No parts provided"}), 400

    full_text = " ".join(book_parts)  # Combine all parts into a single text

    # 🔹 Summarize the text
    summary = summarizer(full_text, max_length=150, min_length=50, do_sample=False)

    return jsonify({"description": summary[0]['summary_text']})

