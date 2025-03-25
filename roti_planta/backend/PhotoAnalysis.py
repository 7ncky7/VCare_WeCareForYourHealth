import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from jamaibase import JamAI, protocol as p
from typing import Dict, Optional

app = Flask(__name__)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png'}

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

class PhotoProcessor:
    def __init__(self, project_id: str, pat: str):
        self.client = JamAI(
            project_id=project_id,
            token=pat
        )
    
    def validate_image(self, image_path: str) -> bool:
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found: {image_path}")
            
        valid_extensions = ['.jpg', '.jpeg', '.png']
        file_ext = os.path.splitext(image_path)[1].lower()
        if file_ext not in valid_extensions:
            raise ValueError(f"Unsupported file format. Use: {valid_extensions}")
            
        return True

    # Simplified function to remove "**" and "---" from text
    # Inside the PhotoProcessor class
    def clean_text(self, text: str) -> str:
        # Remove unwanted Markdown markers
        cleaned = text.replace("**", "").replace("---", "")
        
        # Split the text into lines for processing
        lines = cleaned.split('\n')
        formatted_lines = []
        in_interpretation = False
        
        for line in lines:
            line = line.strip()
            if not line:  # Skip empty lines
                continue
                
            # Add a colon after section headers if not present
            if "What Happened in the Image" in line and not line.endswith(":"):
                line = "What Happened in the Image:"
            elif "Interpretation" in line and not line.endswith(":"):
                line = "Interpretation:"
                in_interpretation = True
            
            # Ensure bullet points under Interpretation are consistently formatted
            if in_interpretation and line.startswith("-"):
                line = line.replace("- ", "• ")  # Replace hyphens with bullet points for better styling
                
            formatted_lines.append(line)
        
        # Join the lines with consistent spacing
        return '\n\n'.join(formatted_lines)

    def process_photo(self, image_path: str) -> Optional[Dict[str, str]]:
        try:
            self.validate_image(image_path)
            
            print(f"Processing photo: {image_path}")
            print("Uploading image...")
            file_response = self.client.file.upload_file(image_path)
            print(f"Upload successful! URI: {file_response.uri}")
            
            print("Analyzing photo...")
            response = self.client.table.add_table_rows(
                table_type=p.TableType.action,
                request=p.RowAddRequest(
                    table_id="Photo_Analysis",
                    data=[{"Image": file_response.uri}],
                    stream=False,
                ),
            )
            
            # Check if rows exist in the response
            if not response.rows:
                print("Error: No rows returned in the response.")
                return None
            
            # Debug: Print the columns available in the first row
            print("Columns in first row:", response.rows[0].columns)
            
            # Attempt to access the output column
            if "Result" not in response.rows[0].columns:
                print("Error: 'Result' column not found in response. Available columns:", list(response.rows[0].columns.keys()))
                return None
            
            # Get the raw result text and clean it
            raw_result = response.rows[0].columns["Result"].text
            cleaned_result = self.clean_text(raw_result)
            
            results = {
                "result": cleaned_result
            }
            return results
            
        except KeyError as ke:
            print(f"KeyError: {str(ke)}. Likely an issue with column name or response structure.")
            return None
        except AttributeError as ae:
            print(f"AttributeError: {str(ae)}. Likely an issue with accessing the .text attribute.")
            return None
        except Exception as e:
            print(f"Unexpected error: {str(e)} (Type: {type(e).__name__})")
            return None

# Initialize the PhotoProcessor with your project ID and PAT
# Replace these with your actual project ID and personal access token
PROJECT_ID = "proj_0c862863be97023ecfeb9eaa"
PAT = "jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026"
processor = PhotoProcessor(PROJECT_ID, PAT)

def allowed_file(filename: str) -> bool:
    return os.path.splitext(filename)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/process-photo', methods=['POST'])
def process_photo():
    # Check if a file is part of the request
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    
    # Check if a file was selected
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    
    # Validate file extension
    if not allowed_file(file.filename):
        return jsonify({"error": f"Unsupported file format. Use: {list(ALLOWED_EXTENSIONS)}"}), 400
    
    # Save the file securely
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)
    
    try:
        # Process the photo using the PhotoProcessor
        result = processor.process_photo(file_path)
        
        # Clean up the uploaded file
        os.remove(file_path)
        
        if result is None:
            return jsonify({"error": "Failed to process the photo"}), 500
        
        return jsonify(result), 200
    
    except Exception as e:
        # Clean up the file in case of an error
        if os.path.exists(file_path):
            os.remove(file_path)
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)