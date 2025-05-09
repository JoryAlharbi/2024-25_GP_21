# idea_generation.py

from flask import Blueprint, request, jsonify
from transformers import pipeline

idea_gen = Blueprint('idea_gen', __name__)  # Blueprint name

generator = pipeline("text-generation", model="gpt2")

@idea_gen.route('/generate-idea', methods=['POST'])
def generate_idea():
    try:
        data = request.get_json()
        print("Incoming data:", data)

        thread_text = data.get('thread_text')
        if not thread_text:
            return jsonify({'error': 'thread_text is required'}), 400

        prompt = f"Here's the story so far:\n{thread_text}\nGive me an idea to continue the story."
        print("Prompt:", prompt)

        result = generator(prompt, max_new_tokens=50, num_return_sequences=1, temperature=0.7)
        print("Raw generation:", result)

        idea = result[0]['generated_text'].replace(prompt, '').strip()
        return jsonify({'idea': idea})

    except Exception as e:
        print("Error:", str(e))
        return jsonify({'error': str(e)}), 500
