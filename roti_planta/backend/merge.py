from flask import Flask, request, jsonify
from jamaibase import JamAI, protocol as p

app = Flask(__name__)

# Chatbot class (same as before)
class Chatbot:
    def __init__(self, project_id: str, api_key: str, table_id: str):
        self.table_id = table_id
        try:
            self.client = JamAI(project_id=project_id, api_key=api_key)
            print(f"Successfully connected to JamAI Base for {table_id}.")
        except Exception as e:
            print(f"Failed to initialize JamAI client for {table_id}: {str(e)}")
            raise

    def chat(self, user_message: str):
        try:
            print(f"User ({self.table_id}): {user_message}")
            print(f"Sending request to JamAI Base for {self.table_id}...")

            response = self.client.table.add_table_rows(
                table_type=p.TableType.chat,
                request=p.RowAddRequest(
                    table_id=self.table_id,
                    data=[{"User": user_message}],
                    stream=False
                )
            )

            ai_response = response.rows[0].columns["AI"].text
            print(f"AI ({self.table_id}): {ai_response}")
            return ai_response

        except Exception as e:
            print(f"Error for {self.table_id}: {str(e)}")
            return "Sorry, something went wrong."

# Initialize chatbots for each table
project_id = "proj_0c862863be97023ecfeb9eaa"
api_key = "jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026"

emotional_support_chatbot = Chatbot(project_id=project_id, api_key=api_key, table_id="EmotionalSupport")
check_symptoms_chatbot = Chatbot(project_id=project_id, api_key=api_key, table_id="CheckSymptoms")
medicine_recommendation_chatbot = Chatbot(project_id=project_id, api_key=api_key, table_id="MedicineRecommendation")

# Define REST API endpoints for each chatbot
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

# Basic health check endpoint
@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "API is running"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)