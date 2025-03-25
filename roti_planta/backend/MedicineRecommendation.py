from flask import Flask, request, jsonify
from jamaibase import JamAI, protocol as p

app = Flask(__name__)

# Initialize the JamAI Chatbot (use your project ID and API key)
class Chatbot:
    def __init__(self, project_id: str, api_key: str):
        try:
            self.client = JamAI(project_id=project_id, api_key=api_key)
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
                    table_id="MedicineRecommendation",
                    data=[{"User": user_message}],
                    stream=False
                )
            )

            ai_response = response.rows[0].columns["AI"].text
            print(f"AI: {ai_response}")
            return ai_response

        except Exception as e:
            print(f"Error: {str(e)}")
            return "Sorry, something went wrong."

# Replace with your actual project ID and API key
chatbot = Chatbot(project_id="proj_0c862863be97023ecfeb9eaa", api_key="jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026")

# Define a REST API endpoint for chat
@app.route('/api/chat', methods=['POST'])
def chat():
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400

    user_message = data['message']
    ai_response = chatbot.chat(user_message)
    return jsonify({"response": ai_response})

# Basic health check endpoint
@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({"status": "API is running"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)