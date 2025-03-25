from flask import Flask, request, jsonify
from jamaibase import JamAI, protocol as p
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)

# Chatbot class to interact with JamAI Base
class Chatbot:
    def __init__(self, project_id: str, api_key: str, table_id: str):
        try:
            self.client = JamAI(project_id=project_id, api_key=api_key)
            self.table_id = table_id
            print("Successfully connected to JamAI Base.")
        except Exception as e:
            print(f"Failed to initialize JamAI client: {str(e)}")
            raise

    def chat(self, user_message: str):
        try:
            print(f"User: {user_message}")
            print("Sending request to JamAI Base...")

            response = self.client.table.add_table_rows(
                table_type=p.TableType.chat,
                request=p.RowAddRequest(
                    table_id=self.table_id,
                    data=[{"User": user_message}],
                    stream=False
                )
            )

            ai_response = response.rows[0].columns["AI"].text
            print(f"AI: {ai_response}")
            return ai_response

        except Exception as e:
            print(f"Error: {str(e)}")
            return f"Sorry, something went wrong: {str(e)}"

# Initialize the chatbot with your project ID, API key, and table ID
chatbot = Chatbot(
    project_id=os.getenv("PROJECT_ID", "proj_0c862863be97023ecfeb9eaa"),
    api_key=os.getenv("JAMAI_API_KEY", "jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026"),
    table_id="UserGuide"  # Chat table ID
)

# Enable CORS
@app.after_request
def after_request(response):
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Headers", "Content-Type,Authorization")
    response.headers.add("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
    return response

# API endpoint to handle chat messages
@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.get_json()
        if not data or "message" not in data:
            return jsonify({"error": "Missing 'message' in request body"}), 400

        message = data["message"]
        response = chatbot.chat(message)
        return jsonify({"response": response})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Health check endpoint
@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "API is running"}), 200

# Run the Flask app
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)