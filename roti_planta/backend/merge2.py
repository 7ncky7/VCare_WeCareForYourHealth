import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from jamaibase import JamAI, protocol as p
from typing import Dict, Optional
import pdfplumber
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud.firestore_v1 import FieldFilter
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Configuration for file uploads
UPLOAD_FOLDER = 'uploads'
ALLOWED_PHOTO_EXTENSIONS = {'.jpg', '.jpeg', '.png'}
ALLOWED_DOCUMENT_EXTENSIONS = {'.pdf'}

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Project ID and API Key
PROJECT_ID = os.getenv("PROJECT_ID", "proj_be2c8d9620ef80fd7a193afa")
API_KEY = os.getenv("JAMAI_API_KEY", "jamai_pat_328b45b69108c037c231e0f5574c5eba79a7f63788f25ecb")

# Initialize Firebase
def initialize_firebase():
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate('vcaretest-8e88b-firebase-adminsdk-fbsvc-72ceb7653a.json')
            firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Failed to initialize Firebase: {str(e)}")
        return None

# Function to retrieve user data by email
def get_user_data(email):
    try:
        db = initialize_firebase()
        users_ref = db.collection('users')
        query = users_ref.where(filter=FieldFilter('email', '==', email)).limit(1)
        results = query.get()
        
        for doc in results:
            user_data = doc.to_dict()
            return user_data
            
        print(f"No user found with email: {email}")
        return None
    except Exception as e:
        print(f"Error retrieving data: {str(e)}")
        return None

# Chatbot class
class Chatbot:
    def __init__(self, project_id: str, api_key: str, table_id: str):
        self.table_id = table_id
        try:
            self.client = JamAI(project_id=project_id, api_key=api_key)
            print(f"Successfully connected to JamAI Base for {table_id}.")
        except Exception as e:
            print(f"Failed to initialize JamAI client for {table_id}: {str(e)}")
            raise

    def clean_text(self, text: str) -> str:
        cleaned = text.replace("", "").replace("*", "")
        return cleaned

    def chat(self, user_message: str):
        try:
            print(f"User ({self.table_id}): {user_message}")
            response = self.client.table.add_table_rows(
                table_type=p.TableType.chat,
                request=p.RowAddRequest(
                    table_id=self.table_id,
                    data=[{"User": user_message}],
                    stream=False
                )
            )
            ai_response = response.rows[0].columns["AI"].text
            cleaned_response = self.clean_text(ai_response)
            print(f"AI ({self.table_id}): {cleaned_response}")
            return cleaned_response
        except Exception as e:
            print(f"Error for {self.table_id}: {str(e)}")
            return f"Sorry, something went wrong: {str(e)}"

# PhotoProcessor class
class PhotoProcessor:
    def __init__(self, project_id: str, pat: str):
        self.client = JamAI(project_id=project_id, token=pat)
    
    def validate_image(self, image_path: str) -> bool:
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found: {image_path}")
        file_ext = os.path.splitext(image_path)[1].lower()
        if file_ext not in ALLOWED_PHOTO_EXTENSIONS:
            raise ValueError(f"Unsupported file format. Use: {ALLOWED_PHOTO_EXTENSIONS}")
        return True

    def clean_text(self, text: str) -> str:
        cleaned = text.replace("", "").replace("---", "")
        lines = cleaned.split('\n')
        formatted_lines = []
        in_interpretation = False
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            if "What Happened in the Image" in line and not line.endswith(":"):
                line = "What Happened in the Image:"
            elif "Interpretation" in line and not line.endswith(":"):
                line = "Interpretation:"
                in_interpretation = True
            if in_interpretation and line.startswith("-"):
                line = line.replace("- ", "• ")
            formatted_lines.append(line)
        
        return '\n\n'.join(formatted_lines)

    def process_photo(self, image_path: str) -> Optional[Dict[str, str]]:
        try:
            self.validate_image(image_path)
            file_response = self.client.file.upload_file(image_path)
            response = self.client.table.add_table_rows(
                table_type=p.TableType.action,
                request=p.RowAddRequest(
                    table_id="Photo_Analysis",
                    data=[{"Image": file_response.uri}],
                    stream=False,
                ),
            )
            if not response.rows or "Result" not in response.rows[0].columns:
                return None
            raw_result = response.rows[0].columns["Result"].text
            cleaned_result = self.clean_text(raw_result)
            return {"result": cleaned_result}
        except Exception as e:
            print(f"Error processing photo: {str(e)}")
            return None

# DocumentProcessor class
class DocumentProcessor:
    def __init__(self, project_id: str, pat: str):
        self.client = JamAI(project_id=project_id, token=pat)
    
    def validate_document(self, doc_path: str) -> bool:
        if not os.path.exists(doc_path):
            raise FileNotFoundError(f"Document not found: {doc_path}")
        file_ext = os.path.splitext(doc_path)[1].lower()
        if file_ext not in ALLOWED_DOCUMENT_EXTENSIONS:
            raise ValueError(f"Unsupported file format. Use: {ALLOWED_DOCUMENT_EXTENSIONS}")
        return True

    def extract_text_from_pdf(self, pdf_path: str) -> str:
        try:
            with pdfplumber.open(pdf_path) as pdf:
                text = "".join(page.extract_text() or "" for page in pdf.pages)
                return text.strip()
        except Exception as e:
            raise RuntimeError(f"Failed to extract text from PDF: {str(e)}")

    def clean_text(self, text: str) -> str:
        return text.replace("", "").replace("---", "")

    def process_document(self, doc_path: str) -> Optional[Dict[str, str]]:
        try:
            self.validate_document(doc_path)
            extracted_text = self.extract_text_from_pdf(doc_path)
            if not extracted_text:
                return None
            response = self.client.table.add_table_rows(
                table_type=p.TableType.action,
                request=p.RowAddRequest(
                    table_id="Report",
                    data=[{"Information": extracted_text}],
                    stream=False,
                ),
            )
            if not response.rows or "Analysis" not in response.rows[0].columns:
                return None
            raw_result = response.rows[0].columns["Analysis"].text
            cleaned_result = self.clean_text(raw_result)
            return {"result": cleaned_result}
        except Exception as e:
            print(f"Error processing document: {str(e)}")
            return None


class DietRecommendationProcessor:
    def __init__(self, project_id: str, api_key: str):
        try:
            self.jamai = JamAI(api_key=api_key, project_id=project_id)
            print("Successfully initialized JamAI for Diet Recommendation.")
        except Exception as e:
            print(f"Failed to initialize JamAI for Diet Recommendation: {str(e)}")
            self.jamai = None

    def format_for_diet_recommendation(self, user_data):
        if not user_data:
            print("No user data to format.")
            return None
        try:
            age = user_data.get('age', 'N/A')
            height = user_data.get('height', 'N/A')
            weight = user_data.get('weight', 'N/A')
            formatted_data = {
                "Age": str(age) if age != 'N/A' else 'N/A',
                "Gender": user_data.get('gender', 'N/A'),
                "Weight": str(weight) if weight != 'N/A' else 'N/A',
                "Height": str(height) if height != 'N/A' else 'N/A',
                "Activity Level": user_data.get('activityLevel', 'N/A'),
                "Dietary Preference": ', '.join(user_data.get('dietaryPreferences', [])),
                "Favourite Cuisine": ', '.join(user_data.get('favouriteCuisines', [])),
                "Food Allergies": ', '.join(user_data.get('foodAllergies', []))
            }
            print("User data formatted successfully for JamAI Base!")
            return formatted_data
        except Exception as e:
            print(f"Error formatting data for JamAI Base: {str(e)}")
            return None

    def clean_meal_plan(self, meal_plan):
        if meal_plan == "Not available":
            return meal_plan
        cleaned = meal_plan.replace("", "").replace("#", "").replace("##", "").replace("###", "").replace("####", "")
        phrases_to_remove = [
            "Breakfast Meal Plan",
            "Lunch Meal Plan",
            "Dinner Meal Plan",
            "Fiber-Rich, Low-GI Foods and Lean Proteins"
        ]
        for phrase in phrases_to_remove:
            cleaned = cleaned.replace(phrase, "")
        lines = cleaned.split('\n')
        formatted_lines = []
        for line in lines:
            line = line.strip()
            if line:
                line = line.replace("Carbs:", "Carbs: ").replace("Protein:", "Protein: ").replace("Fat:", "Fat: ").replace("Fiber:", "Fiber: ").replace("Calories:", "Total Calories: ")
                if not line.startswith("1.") and not line.startswith("2.") and not line.startswith("3.") and not line.startswith("-") and not line.startswith("Total "):
                    continue
                formatted_lines.append(line)
        return '\n'.join(formatted_lines)

    def add_to_diet_recommendation_table(self, formatted_data):
        print("Attempting to add data to Diet_Recommendation table...")
        try:
            if not self.jamai:
                print("JamAI client not initialized.")
                return None
            
            # Prepare the data for the Diet_Recommendation table
            row_data = {
                "Age": formatted_data["Age"],
                "Gender": formatted_data["Gender"],
                "Weight": formatted_data["Weight"],
                "Height": formatted_data["Height"],
                "Activity Level": formatted_data["Activity Level"],
                "Dietary Preference": formatted_data["Dietary Preference"],
                "Favourite Cuisine": formatted_data["Favourite Cuisine"],
                "Food Allergies": formatted_data["Food Allergies"]
            }

            # Add a row to the Diet_Recommendation table
            print("Sending request to JamAI Base...")
            response = self.jamai.table.add_table_rows(
                table_type=p.TableType.action,
                request=p.RowAddRequest(
                    table_id="Diet_Recommendation",
                    data=[row_data],
                    stream=False
                )
            )

            # Debug: Print the response type and structure
            print("JamAI Response Type:", type(response))
            print("JamAI Response:", response)

            # Check the type of response
            if isinstance(response, p.GenTableRowsChatCompletionChunks):
                print("Received a streaming response from JamAI Base.")
                recommendations = {
                    "Breakfast": "Not available",
                    "Lunch": "Not available",
                    "Dinner": "Not available"
                }
                # Handle streaming response
                for chunk in response:
                    if isinstance(chunk, tuple) and len(chunk) > 1 and chunk[0] == 'rows':
                        # Extract the GenTableChatCompletionChunks object
                        table_chunks = chunk[1][0]  # First row
                        columns = table_chunks.columns
                        print("Streaming Columns:", columns)
                        # Extract meal plans from the columns
                        if 'Breakfast' in columns:
                            breakfast_chunk = columns['Breakfast']
                            if breakfast_chunk.choices and breakfast_chunk.choices[0].message.content:
                                recommendations["Breakfast"] = self.clean_meal_plan(breakfast_chunk.choices[0].message.content)
                        if 'Lunch' in columns:
                            lunch_chunk = columns['Lunch']
                            if lunch_chunk.choices and lunch_chunk.choices[0].message.content:
                                recommendations["Lunch"] = self.clean_meal_plan(lunch_chunk.choices[0].message.content)
                        if 'Dinner' in columns:
                            dinner_chunk = columns['Dinner']
                            if dinner_chunk.choices and dinner_chunk.choices[0].message.content:
                                recommendations["Dinner"] = self.clean_meal_plan(dinner_chunk.choices[0].message.content)
                        break  # We only need the 'rows' chunk
                print("Processed streaming response into meal plans.")
                print("Warning: Received a streaming response despite stream=False. This may indicate a misconfiguration.")
            elif isinstance(response, p.ChatCompletionChunk):
                print("Received a ChatCompletionChunk response from JamAI Base.")
                recommendations = {
                    "Breakfast": "Not available",
                    "Lunch": "Not available",
                    "Dinner": "Not available"
                }
                # Handle ChatCompletionChunk response
                content = response.choices[0].message.content if response.choices and response.choices[0].message else "Not available"
                print("Extracted Content:", content)
                # Parse the content into recommendations
                content = content.lower()
                if "breakfast:" in content:
                    breakfast_section = content.split("breakfast:")[1].split("lunch:")[0] if "lunch:" in content else content.split("breakfast:")[1]
                    recommendations["Breakfast"] = self.clean_meal_plan(breakfast_section.strip())
                if "lunch:" in content:
                    lunch_section = content.split("lunch:")[1].split("dinner:")[0] if "dinner:" in content else content.split("lunch:")[1]
                    recommendations["Lunch"] = self.clean_meal_plan(lunch_section.strip())
                if "dinner:" in content:
                    dinner_section = content.split("dinner:")[1]
                    recommendations["Dinner"] = self.clean_meal_plan(dinner_section.strip())
                print("Processed ChatCompletionChunk response into meal plans.")
                print("Warning: Received a ChatCompletionChunk response, which is unexpected for an action table. This may indicate a misconfiguration.")
            else:
                # Handle non-streaming response (expected behavior for an action table)
                print("Received a non-streaming response from JamAI Base.")
                if hasattr(response, 'rows') and response.rows:
                    row = response.rows[0]  # Access the first row
                    columns = row.columns  # Access the columns dictionary
                    print("Non-Streaming Columns:", columns)
                    recommendations = {
                        "Breakfast": self.clean_meal_plan(columns.get("Breakfast", {}).get("text", "Not available")),
                        "Lunch": self.clean_meal_plan(columns.get("Lunch", {}).get("text", "Not available")),
                        "Dinner": self.clean_meal_plan(columns.get("Dinner", {}).get("text", "Not available"))
                    }
                else:
                    print("Error: No rows returned in the response or unexpected response format.")
                    recommendations = None

            return recommendations

        except Exception as e:
            print(f"Error interacting with JamAI Base: {str(e)}")
            return None


# Initialize processors
emotional_support_chatbot = Chatbot(project_id=PROJECT_ID, api_key=API_KEY, table_id="EmotionalSupport")
check_symptoms_chatbot = Chatbot(project_id=PROJECT_ID, api_key=API_KEY, table_id="CheckSymptoms")
medicine_recommendation_chatbot = Chatbot(project_id=PROJECT_ID, api_key=API_KEY, table_id="MedicineRecommendation")
user_guide_chatbot = Chatbot(project_id=PROJECT_ID, api_key=API_KEY, table_id="UserGuide")
photo_processor = PhotoProcessor(PROJECT_ID, API_KEY)
document_processor = DocumentProcessor(PROJECT_ID, API_KEY)
diet_processor = DietRecommendationProcessor(PROJECT_ID, API_KEY)

# Enable CORS
@app.after_request
def after_request(response):
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Headers", "Content-Type,Authorization")
    response.headers.add("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
    return response

# Endpoints
@app.route('/api/get-user-data', methods=['POST'])
def get_user_data_endpoint():
    try:
        data = request.get_json()
        user_email = data.get('email')
        if not user_email:
            return jsonify({"error": "Email is required"}), 400
        user_data = get_user_data(user_email)
        if not user_data:
            return jsonify({"error": "User not found"}), 404
        return jsonify(user_data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/emotional-support', methods=['POST'])
def emotional_support():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    user_message = data['message']
    ai_response = emotional_support_chatbot.chat(user_message)
    return jsonify({"response": ai_response})

@app.route('/api/check-symptoms', methods=['POST'])
def check_symptoms():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    user_message = data['message']
    ai_response = check_symptoms_chatbot.chat(user_message)
    return jsonify({"response": ai_response})

@app.route('/api/medicine-recommendation', methods=['POST'])
def medicine_recommendation():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    user_message = data['message']
    ai_response = medicine_recommendation_chatbot.chat(user_message)
    return jsonify({"response": ai_response})

@app.route('/api/user-guide', methods=['POST'])
def user_guide():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    message = data["message"]
    response = user_guide_chatbot.chat(message)
    return jsonify({"response": response})

@app.route('/api/process-photo', methods=['POST'])
def process_photo():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    if not os.path.splitext(file.filename)[1].lower() in ALLOWED_PHOTO_EXTENSIONS:
        return jsonify({"error": f"Unsupported file format. Use: {list(ALLOWED_PHOTO_EXTENSIONS)}"}), 400
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)
    try:
        result = photo_processor.process_photo(file_path)
        os.remove(file_path)
        if result is None:
            return jsonify({"error": "Failed to process the photo"}), 500
        return jsonify(result), 200
    except Exception as e:
        if os.path.exists(file_path):
            os.remove(file_path)
        return jsonify({"error": str(e)}), 500

@app.route('/api/process-document', methods=['POST'])
def process_document():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    if not os.path.splitext(file.filename)[1].lower() in ALLOWED_DOCUMENT_EXTENSIONS:
        return jsonify({"error": f"Unsupported file format. Use: {list(ALLOWED_DOCUMENT_EXTENSIONS)}"}), 400
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)
    try:
        result = document_processor.process_document(file_path)
        os.remove(file_path)
        if result is None:
            return jsonify({"error": "Failed to process the document"}), 500
        return jsonify(result), 200
    except Exception as e:
        if os.path.exists(file_path):
            os.remove(file_path)
        return jsonify({"error": str(e)}), 500

@app.route('/api/get-diet-recommendations', methods=['POST'])
def get_diet_recommendations():
    try:
        data = request.get_json()
        user_email = data.get('email')
        if not user_email:
            return jsonify({"error": "Email is required"}), 400
        user_data = get_user_data(user_email)
        if not user_data:
            return jsonify({"error": "User not found"}), 404
        formatted_data = diet_processor.format_for_diet_recommendation(user_data)
        if not formatted_data:
            return jsonify({"error": "Failed to format data"}), 500
        recommendations = diet_processor.add_to_diet_recommendation_table(formatted_data)
        if not recommendations:
            return jsonify({"error": "Failed to generate recommendations"}), 500
        response = {
            "user_data": user_data,
            "recommendations": recommendations
        }
        return jsonify(response), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "API is running"}), 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)