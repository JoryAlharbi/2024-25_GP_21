from transformers import T5ForConditionalGeneration, T5Tokenizer
from flask import Blueprint, request, jsonify

enhancer_neo = Blueprint('enhancer_neo', __name__)  # keep the same name

# Load grammar correction model and tokenizer
tokenizer = T5Tokenizer.from_pretrained("vennify/t5-base-grammar-correction")
model = T5ForConditionalGeneration.from_pretrained("vennify/t5-base-grammar-correction")

# Function to fix grammar and punctuation
def enhance_grammar(text):
    input_text = f"fix: {text}"
    inputs = tokenizer.encode(input_text, return_tensors="pt", max_length=512, truncation=True)

    try:
        outputs = model.generate(
            inputs,
            max_length=512,
            num_beams=5,
            early_stopping=True
        )
        corrected_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        return corrected_text
    except Exception as e:
        print(f"Error during grammar enhancement: {e}")
        return "Error in enhancement"

@enhancer_neo.route('/api/enhance', methods=['POST'])
def enhance_text():
    data = request.get_json()
    original = data.get("text", "")
    
    if not original:
        return jsonify({"error": "No text provided"}), 400

    try:
        enhanced_text = enhance_grammar(original)

        if enhanced_text == "Error in enhancement":
            return jsonify({"error": "There was an issue with the grammar enhancement"}), 500

        return jsonify({"enhanced_text": enhanced_text})

    except Exception as e:
        return jsonify({"error": str(e)}), 500
