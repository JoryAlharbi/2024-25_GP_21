from flask import Flask, request, jsonify
import os
import openai
from openai import OpenAI
import firebase_admin
from firebase_admin import credentials, storage, firestore
import requests
from flask_cors import CORS
import time
import random
import string
import re
import spacy
from google.api_core.exceptions import NotFound, GoogleAPICallError
import uuid

#####
from idea_generation import idea_gen
from Book_Description  import description_bp
from Book_Summary import BookSum_bp
from Enhancer import enhancer_neo

####

import os
import openai
from firebase_admin import credentials


openai.api_key = os.getenv("OPENAI_API_KEY")  
cred = credentials.Certificate(os.getenv("FIREBASE_KEY"))  


# Initialize Flask app
app = Flask(__name__)
CORS(app, origins=["http://localhost:3000", "http://127.0.0.1:5000"])  # Add your Flutter app's URL

# Initialize OpenAI API (replace with your actual OpenAI API key)

# Initialize Firebase Admin SDK

firebase_admin.initialize_app(cred, {
    'storageBucket': 'rawae-167dd.appspot.com'
})
db_firestore = firestore.client()

# Load spaCy model for NLP

nlp = spacy.load("en_core_web_sm")


# Route to process story and generate/upload an image
@app.route('/generate-image', methods=['POST'])
def generate_and_upload_image():
    print("Received request to generate and upload image.")  # Log the start of the function
    data = request.json
    print(f"Request Data: {data}")  # Log the incoming request

    story_part = data.get("story_text")
    part_id = data.get("part_id")  # Optional: Part document ID
    thread_id = data.get("thread_id")  # Optional: Thread document ID
    additional = data.get('additional', None)  # This will now be a boolean
    title = data.get('title')
    genres = data.get('genres')
   
    if additional:  # Check if 'additional' is True
        print("Additional text detected.")
        result= EditDescription(thread_id,part_id,story_part)
        return result
    if additional:  # Check if 'additional' is True
        print("Additional text detected.")
        result= EditDescription(thread_id,part_id,story_part)
        return result
    
    if title and genres:
        print("cover  ")
   
        print("try cover  ")

        # Create a detailed prompt for DALL-E
        genre_text = ', '.join(genres)
        prompt = f"Create a book cover for a {genre_text} book titled '{title}'. The design should be professional and artistic, with appropriate mood and symbolism for the genres. Make it visually striking and suitable for a book cover."

        # Generate image with DALL-E
        response = client.images.generate(
            prompt=prompt,
            n=1,
            size="512x512"
        )
        image_url = response.data[0].url
        image_data = requests.get(image_url).content
        bucket = storage.bucket()
        # Upload the image to Firebase Storage
        blob = bucket.blob(f"book_covers/{title}_{uuid.uuid4().hex}.png")  # Save with a unique name
        blob.upload_from_string(image_data, content_type="image/png")

        # Make the image publicly accessible
        blob.make_public()

        # Get the public URL
        firebase_url = blob.public_url
        print(firebase_url)

        # Return the Firebase URL
        return jsonify({'image_url': firebase_url})
        # Option 1: Return DALL-E URL directly

    if not story_part:
        print("Error: Story part is required")
        return jsonify({"error": "Story part is required"}), 400

    try:
        print("Extracting characters from story part...")  # Log before extracting characters
        characters = extract_characters(story_part,thread_id,part_id)
       
        if not characters:
            print("Error: No characters found in the story part")
            return jsonify({"error": "No characters found in the story part"}), 404

        # Generate the prompt for the image
        prompt = ", ".join([f"{char['name']} with {char['description']}" for char in characters])
        print(f"Generated prompt for image: {prompt}")  # Log generated prompt

        # Generate an image using OpenAI
        response = client.images.generate(
            prompt = f"Digital art of a portrait of {prompt}, head-and-shoulders shot, white background, cute Pixar character.",
            n=1,
            size="512x512"
        )
        print(f"Image generated with response: {response}")  # Log the OpenAI response

        # Extract the image URL from the response
        image_url = response.data[0].url
        print(f"Image URL: {image_url}")  # Log the image URL
       
        # Download the image locally
        local_file_path = 'generated_image.png'
        download_image(image_url, local_file_path)

        # Upload the image to Firebase Storage
        firebase_file_name = generate_unique_name(part_id)
        public_url = upload_to_firebase(local_file_path, firebase_file_name)

        # Save metadata to Firestore with character id
        character_id = characters[0]['id']  # Assuming we're working with the first character
        character_doc_id = save_image_metadata_to_firestore(prompt, public_url, part_id, thread_id, character_id, characters[0]['name'],characters[0]['description'])

        # Link Character with Part or Thread
        if part_id:
            link_character_to_part(thread_id, part_id, character_doc_id,public_url)  # Pass thread_id, part_id, and character_doc_id
        if thread_id:
            link_character_to_thread(thread_id, character_doc_id)

        print(f"Public URL: {public_url}, Characters: {characters}")  # Log the final response
        return jsonify({"public_url": public_url, "characters": characters})

    except Exception as e:
        print(f"Error: {str(e)}")  # Log any error
        return jsonify({"error": str(e)}), 500


#################################



# Helper function to extract physical descriptions
import re

def extract_physical_description(story_part):
    print("Extracting physical description...")  # Log before extraction
   
    # List of physical features we want to capture
    physical_keywords = ['hair', 'eyes', 'skin', 'height', 'build', 'face', 'weight', 'features',
                         'complexion', 'nose', 'lips', 'ears', 'eyebrows', 'freckles', 'teeth']

    # Join the physical features into a string to be used in the regex
    physical_keywords_str = "|".join(physical_keywords)
   
    # Regex to capture different descriptions with adjectives and conjunctions
    pattern = r"\b([A-Z][a-z]+)\b\s*(?:with|and)?\s*((?:[\w\s,]+(?:\s+and\s+)?[\w\s,]+)?(?:\s*(transformed\s+into|turned\s+into|became)\s+)?(?:\s*" + physical_keywords_str + r"\b))"
   
    # Find all matches using the pattern
    matches = re.findall(pattern, story_part, re.IGNORECASE)
   
    # If matches are found, extract the descriptions
    description = [match[1].strip() for match in matches]
   
    description_text = " ".join(description)
    print(f"Extracted description: {description_text}")  # Log the extracted description
    return description_text


# Check if character exists in Firestore
def get_character_from_firestore(character_name,thread_id):
    print(f"Checking if character '{character_name}' exists in Firestore within thread ID '{thread_id}'...")  # Log before checking
    characters_ref = db_firestore.collection("Character")
    query = characters_ref.where('name', '==', character_name).where('threadID', '==', thread_id).limit(1).get()
    if query:
        doc = query[0]
        character_data = doc.to_dict()
        character_data["id"] = doc.id  # Include Firestore document ID
        print(f"Character found: {character_data}")  # Log found character
        return character_data
    print("Character not found.")  # Log if not found
    return None


# Save or update a character in Firestore
def save_or_update_character(character_name, description, thread_id, part_ID):
    existing_character = get_character_from_firestore(character_name, thread_id)
   
    # Check if a character exists and update description
    if existing_character:
        existing_description = existing_character.get("description", "")
        # Safely concatenate existing and new descriptions
        updated_description = f"{existing_description} {description}".strip() if existing_description else description
        character_ref = db_firestore.collection("Character").document(existing_character["id"])
        character_ref.update({"description": updated_description})
        print(f"Updated character: {existing_character['id']}")  # Log update
        return {"id": existing_character["id"], "name": character_name, "description": updated_description}
   
    # If no character exists, create a new one
    else:
        update_time, doc_ref = db_firestore.collection("Character").add({
            "name": character_name,
            "description": description,
            "threadID": thread_id,
            "partID": part_ID,
            "timestamp": firestore.SERVER_TIMESTAMP
        })
        print(f"Created new character: {doc_ref.id}")
        print(f"update_timer: {update_time}")
       
        return {"id": doc_ref.id, "name": character_name, "description": description}

################ function for the book cover 
def generate_cover(title,genres):
    try:
        print("try cover  ")

        # Create a detailed prompt for DALL-E
        genre_text = ', '.join(genres)
        prompt = f"Create a book cover for a {genre_text} book titled '{title}'. The design should be professional and artistic, with appropriate mood and symbolism for the genres. Make it visually striking and suitable for a book cover."

        # Generate image with DALL-E
        response = openai.Image.generate(
            prompt=prompt,
            n=1,
            size="512x512"
        )
         
        print("response  "+response)
        image_url = response['data'][0]['url']

        # Option 1: Return DALL-E URL directly
        return jsonify({'image_url': image_url})

    except Exception as e:
        # Option 2: Handle errors and return a message
        return jsonify({'error': str(e)}), 500



# Download image from a URL
def download_image(image_url, file_path):
    print(f"Downloading image from {image_url}...")  # Log before downloading
    response = requests.get(image_url)
    with open(file_path, 'wb') as f:
        f.write(response.content)
    print(f"Image downloaded to {file_path}")  # Log after download


# Upload image to Firebase Storage
def upload_to_firebase(file_path, destination_blob_name):
    print(f"Uploading image to Firebase: {destination_blob_name}")  # Log before uploading
    bucket = storage.bucket()
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(file_path)
    blob.make_public()
    public_url = blob.public_url
    print(f"Image uploaded, public URL: {public_url}")  # Log the public URL
    return public_url


# Save image metadata to Firestore
def save_image_metadata_to_firestore(prompt, file_url, part_id, thread_id, character_id,name,description):
    print(f"Saving image metadata to Firestore...")  # Log before saving
    doc_ref = db_firestore.collection("Character").add({
        "prompt": prompt,
        "url": file_url,
        "timestamp": firestore.SERVER_TIMESTAMP,
        "part": part_id,
        "thread": thread_id,
        "characterId": character_id,
        "CharacterName":name,
        "description":description
    })
    print(f"Image metadata saved, doc ID: {character_id}")  # Log document ID
    return character_id

#######################################################################################################################################
# Link character to part in Firestore
def link_character_to_part(thread_id, part_id, character_id,url):
    print(f"Linking character {character_id} to part {part_id} inside thread {thread_id}")  # Log linking
    # Reference the thread document
    thread_ref = db_firestore.collection("Thread").document(thread_id)
   
    # Get the part reference from the thread's subcollection "Part"
    part_ref = thread_ref.collection("Parts").document(part_id)
   
    # Update the part document with the characterId
    part_ref.update({"characterId": character_id,
                     "url":url})

########################################################################################################################################


def link_character_to_thread(thread_id, character_id):
    print(f"Linking character {character_id} to thread {thread_id}")  # Log linking
    thread_ref = db_firestore.collection("Thread").document(thread_id)
    thread_ref.update({"characterId": character_id})  # Use character's ID


# Generate unique Firebase file name
def generate_unique_name(part_id):
    print(f"Generating unique file name for part {part_id}")  # Log name generation
    timestamp = int(time.time())
    random_string = ''.join(random.choices(string.ascii_letters + string.digits, k=6))
    unique_name = f'{part_id}_{timestamp}_{random_string}.png'
    print(f"Generated unique name: {unique_name}")  # Log the generated name
    return unique_name

def extract_characters(story_part,thread_id,part_ID):
    print("Extracting characters from story part...")  # Log before extraction
    doc = nlp(story_part)
    characters = []

    # If spaCy does not find any person entities, we could manually attempt to identify names
    if not doc.ents:
        # Attempt to find names manually (you can add more sophisticated checks)
        print("No entities found, trying manual extraction...")
        possible_names = re.findall(r"\b[A-Z][a-z]+(?:\s[A-Z][a-z]+)?\b", story_part)
        print(f"Manually extracted names: {possible_names}")
       
        for name in possible_names:
            physical_description = extract_physical_description(story_part)
            character_data = save_or_update_character(name, physical_description,thread_id,part_ID)
            characters.append(character_data)
    else:
        for ent in doc.ents:
            if ent.label_ == "PERSON":
                character_name = ent.text.strip()
                print(f"Found character: {character_name}")  # Log found character
                physical_description = extract_physical_description(story_part)
                character_data = save_or_update_character(character_name, physical_description,thread_id,part_ID)
                characters.append(character_data)

    return characters
def EditDescription(thread_id,part_id,newEditDescription):
    print("Editing description...")  # Log before editing
    response = client.images.generate(
                prompt = f"Digital art of a portrait of {newEditDescription}, head-and-shoulders shot, white background, cute Pixar character.",
                n=1,
                size="512x512"
            )
    print(f"Image generated with response: {newEditDescription}")  # Log the OpenAI response
            # Extract the image URL from the response
    image_url = response.data[0].url
    print(f"Image URL: {image_url}")  # Log the image URL
           
            # Download the image locally
    local_file_path = 'generated_image.png'
    download_image(image_url, local_file_path)
    firebase_file_name = generate_unique_name(part_id)
    public_url = upload_to_firebase(local_file_path, firebase_file_name)

        # Save metadata to Firestore with character id
    character_id = get_character_id(thread_id, part_id)  # Assuming we're working with the first character
    character_doc_id = update_character_description(character_id,newEditDescription)

        # Link Character with Part or Thread
    if part_id:
            link_character_to_part(thread_id, part_id, character_id,public_url)  # Pass thread_id, part_id, and character_doc_id
    if thread_id:
            link_character_to_thread(thread_id, character_doc_id)

    return jsonify({"public_url": public_url})


def update_character_description(character_id, new_description):
    print(f"Updating description for character ID: {character_id}...")  # Log before updating
    try:
        # Reference the specific document in the "Character" collection
        doc_ref = db_firestore.collection("Character").document(character_id)
       
        # Update the description field
        doc_ref.update({
            "description": new_description
        })
       
        print(f"Description updated successfully for character ID: {character_id}")  # Log success
   
    except Exception as e:
        print(f"Failed to update description for character ID: {character_id}, Error: {e}")  # Log any error



def get_character_id(thread_id, part_id):
    try:
        print(f"Fetching character ID for thread ID: {thread_id}, part ID: {part_id}...")

        # Reference the thread document
        thread_ref = db_firestore.collection("Thread").document(thread_id)

        # Reference the part document inside the thread's "Parts" subcollection
        part_ref = thread_ref.collection("Parts").document(part_id)

        # Get the document data
        part_doc = part_ref.get()
        if part_doc.exists:
            # Extract and return the "characterId" field
            character_id = part_doc.to_dict().get("characterId")
            if character_id:
                print(f"Found character ID: {character_id}")
                return character_id
            else:
                print("characterId field is missing or empty.")
                return None
        else:
            print(f"No part found with ID: {part_id} in thread ID: {thread_id}")
            return None
    except NotFound as e:
        print(f"Document not found: {e}")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None




app.register_blueprint(idea_gen)
app.register_blueprint(description_bp)
app.register_blueprint(BookSum_bp)
app.register_blueprint(enhancer_neo)


if __name__ == "__main__":
    app.run(debug=True)
