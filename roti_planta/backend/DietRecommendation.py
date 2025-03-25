from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud.firestore_v1 import FieldFilter
from jamaibase import JamAI, protocol as p

app = Flask(__name__)

# Initialize Firebase
def initialize_firebase():
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate('vcaretest-8e88b-firebase-adminsdk-fbsvc-72ceb7653a.json')
            firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        return None

# Initialize JamAI
def initialize_jamai():
    api_key = "jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026"
    project_id = "proj_0c862863be97023ecfeb9eaa"
    try:
        jamai = JamAI(api_key=api_key, project_id=project_id)
        return jamai
    except Exception as e:
        return None

def get_user_data(email):
    try:
        db = initialize_firebase()
        
        # Query the 'users' collection by email using the filter keyword
        users_ref = db.collection('users')
        query = users_ref.where(filter=FieldFilter('email', '==', email)).limit(1)
        results = query.get()
        
        # Get the first document from the results
        for doc in results:
            user_data = doc.to_dict()
            print("User data retrieved successfully!")
            return user_data
            
        print(f"No user found with email: {email}")
        return None
        
    except Exception as e:
        print(f"Error retrieving data: {str(e)}")
        return None

# Function to format user data for JamAI Base Diet_Recommendation table
def format_for_diet_recommendation(user_data):
    if not user_data:
        print("No user data to format.")
        return None
    
    try:
        # Convert Age, Height, and Weight to strings
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

# Function to clean up meal plan text (remove Markdown markers and unwanted phrases)
def clean_meal_plan(meal_plan):
    if meal_plan == "Not available":
        return meal_plan
    # Remove Markdown markers
    cleaned = meal_plan.replace("**", "").replace("#", "").replace("##", "").replace("###", "").replace("####", "")
    # Remove unwanted phrases
    phrases_to_remove = [
        "Breakfast Meal Plan",
        "Lunch Meal Plan",
        "Dinner Meal Plan",
        "Fiber-Rich, Low-GI Foods and Lean Proteins"
    ]
    for phrase in phrases_to_remove:
        cleaned = cleaned.replace(phrase, "")
    # Split into lines and clean up spacing
    lines = cleaned.split('\n')
    formatted_lines = []
    for line in lines:
        line = line.strip()
        if line:  # Only include non-empty lines
            # Add proper spacing for nutrients (e.g., Carbs: 71g)
            line = line.replace("Carbs:", "Carbs: ").replace("Protein:", "Protein: ").replace("Fat:", "Fat: ").replace("Fiber:", "Fiber: ").replace("Total Calories:", "Total Calories: ")
            # Skip lines that are just numbers or empty after cleaning
            if not line.startswith("1.") and not line.startswith("2.") and not line.startswith("3.") and not line.startswith("-") and not line.startswith("Total "):
                continue
            formatted_lines.append(line)
    return '\n'.join(formatted_lines)

# Function to add a row to the Diet_Recommendation table and retrieve diet recommendations
def add_to_diet_recommendation_table(formatted_data):
    print("Attempting to add data to Diet_Recommendation table...")
    try:
        jamai = initialize_jamai()
        
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
        response = jamai.add_table_rows(
            "action",
            p.RowAddRequest(
                table_id="Diet_Recommendation",
                data=[row_data],
                stream=False
            )
        )

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
                    # Extract meal plans from the columns
                    if 'Breakfast' in columns:
                        breakfast_chunk = columns['Breakfast']
                        if breakfast_chunk.choices and breakfast_chunk.choices[0].message.content:
                            recommendations["Breakfast"] = clean_meal_plan(breakfast_chunk.choices[0].message.content)
                    if 'Lunch' in columns:
                        lunch_chunk = columns['Lunch']
                        if lunch_chunk.choices and lunch_chunk.choices[0].message.content:
                            recommendations["Lunch"] = clean_meal_plan(lunch_chunk.choices[0].message.content)
                    if 'Dinner' in columns:
                        dinner_chunk = columns['Dinner']
                        if dinner_chunk.choices and dinner_chunk.choices[0].message.content:
                            recommendations["Dinner"] = clean_meal_plan(dinner_chunk.choices[0].message.content)
                    break  # We only need the 'rows' chunk
            print("Processed streaming response into meal plans.")
            print("Warning: Received a streaming response despite stream=False.")
        else:
            # Handle non-streaming response (expected behavior)
            print("Received a non-streaming response from JamAI Base.")
            if response and hasattr(response, 'items'):
                row = response.items[0]
                recommendations = {
                    "Breakfast": clean_meal_plan(row.get("Breakfast", "Not available")),
                    "Lunch": clean_meal_plan(row.get("Lunch", "Not available")),
                    "Dinner": clean_meal_plan(row.get("Dinner", "Not available"))
                }
            else:
                print("No recommendations generated.")
                recommendations = None

        return recommendations

    except Exception as e:
        print(f"Error interacting with JamAI Base: {str(e)}")
        return None

# REST API Endpoint
@app.route('/api/get_diet_recommendations', methods=['POST'])
def get_diet_recommendations():
    try:
        # Get email from Flutter request
        data = request.get_json()
        user_email = data.get('email')

        if not user_email:
            return jsonify({"error": "Email is required"}), 400

        # Retrieve and process data
        user_data = get_user_data(user_email)
        if not user_data:
            return jsonify({"error": "User not found"}), 404

        formatted_data = format_for_diet_recommendation(user_data)
        if not formatted_data:
            return jsonify({"error": "Failed to format data"}), 500

        recommendations = add_to_diet_recommendation_table(formatted_data)
        if not recommendations:
            return jsonify({"error": "Failed to generate recommendations"}), 500

        # Return user data and recommendations as JSON
        response = {
            "user_data": user_data,
            "recommendations": recommendations
        }
        return jsonify(response), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)