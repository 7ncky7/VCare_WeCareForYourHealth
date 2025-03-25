import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from jamaibase import JamAI, protocol as p
from typing import Dict, Optional
import pdfplumber  # Added for PDF text extraction

app = Flask(__name__)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'.pdf'}  # Only allow PDF files

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

class DocumentProcessor:
    def __init__(self, project_id: str, pat: str):
        self.client = JamAI(
            project_id=project_id,
            token=pat
        )
    
    def validate_document(self, doc_path: str) -> bool:
        if not os.path.exists(doc_path):
            raise FileNotFoundError(f"Document not found: {doc_path}")
            
        valid_extensions = ['.pdf']
        file_ext = os.path.splitext(doc_path)[1].lower()
        if file_ext not in valid_extensions:
            raise ValueError(f"Unsupported file format. Use: {valid_extensions}")
            
        return True

    # Function to extract text from a PDF file
    def extract_text_from_pdf(self, pdf_path: str) -> str:
        try:
            with pdfplumber.open(pdf_path) as pdf:
                text = ""
                for page in pdf.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + "\n"
                return text.strip()
        except Exception as e:
            raise RuntimeError(f"Failed to extract text from PDF: {str(e)}")

    # Simplified function to remove "**" and "---" from text
    def clean_text(self, text: str) -> str:
        cleaned = text.replace("**", "").replace("---", "")
        return cleaned

    def process_document(self, doc_path: str) -> Optional[Dict[str, str]]:
        try:
            self.validate_document(doc_path)
            
            print(f"Processing document: {doc_path}")
            
            # Extract text from the PDF
            print("Extracting text from PDF...")
            extracted_text = self.extract_text_from_pdf(doc_path)
            if not extracted_text:
                print("Error: No text extracted from the PDF.")
                return None
            print("Text extraction successful!")
            
            print("Analyzing extracted text...")
            response = self.client.table.add_table_rows(
                table_type=p.TableType.action,
                request=p.RowAddRequest(
                    table_id="Report",
                    data=[{"Information": extracted_text}],
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
            if "Analysis" not in response.rows[0].columns:
                print("Error: 'Analysis' column not found in response. Available columns:", list(response.rows[0].columns.keys()))
                return None
            
            # Get the raw result text and clean it
            raw_result = response.rows[0].columns["Analysis"].text
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

# Initialize the DocumentProcessor with your project ID and PAT
PROJECT_ID = "proj_0c862863be97023ecfeb9eaa"
PAT = "jamai_pat_3c20b2252e4d3ff6f442b3035db6e15ead140db6f1eef026"
processor = DocumentProcessor(PROJECT_ID, PAT)

def allowed_file(filename: str) -> bool:
    return os.path.splitext(filename)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/process-document', methods=['POST'])
def process_document():
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
        # Process the document using the DocumentProcessor
        result = processor.process_document(file_path)
        
        # Clean up the uploaded file
        os.remove(file_path)
        
        if result is None:
            return jsonify({"error": "Failed to process the document"}), 500
        
        return jsonify(result), 200
    
    except Exception as e:
        # Clean up the file in case of an error
        if os.path.exists(file_path):
            os.remove(file_path)
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)