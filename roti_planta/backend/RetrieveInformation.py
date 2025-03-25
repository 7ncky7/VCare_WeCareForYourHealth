import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from google.cloud.firestore_v1 import FieldFilter  # Import FieldFilter for Firestore query

# Initialize Firebase Admin SDK
def initialize_firebase():
    try:
        # Check if app is already initialized to avoid duplicate initialization
        if not firebase_admin._apps:
            # Replace with the path to your service account key file
            cred = credentials.Certificate('vcaretest-8e88b-firebase-adminsdk-fbsvc-72ceb7653a.json')
            firebase_admin.initialize_app(cred)
        return firestore.client()
    except FileNotFoundError:
        print("Error: Firebase service account key file not found. Please check the file path.")
        raise
    except Exception as e:
        print(f"Error initializing Firebase: {str(e)}")
        raise

# Function to retrieve user data by email
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
            return user_data
            
        print(f"No user found with email: {email}")
        return None
        
    except Exception as e:
        print(f"Error retrieving data: {str(e)}")
        return None

# Function to display user data in a formatted way
def display_user_data(user_data):
    if user_data:
        print("User Information:")
        print(f"Age: {user_data.get('age', 'N/A')}")
        print(f"Gender: {user_data.get('gender', 'N/A')}")
        
        # Safely handle height and weight to ensure they are numeric
        height = user_data.get('height', 'N/A')
        weight = user_data.get('weight', 'N/A')
        print(f"Height: {height if height != 'N/A' else 'N/A'} {'cm' if isinstance(height, (int, float)) else ''}")
        print(f"Weight: {weight if weight != 'N/A' else 'N/A'} {'kg' if isinstance(weight, (int, float)) else ''}")
        
        print(f"Activity Level: {user_data.get('activityLevel', 'N/A')}")
        print(f"Dietary Preferences: {', '.join(user_data.get('dietaryPreferences', [])) or 'None'}")
        print(f"Favorite Cuisines: {', '.join(user_data.get('favouriteCuisines', [])) or 'None'}")
        print(f"Food Allergies: {', '.join(user_data.get('foodAllergies', [])) or 'None'}")
    else:
        print("No data to display")

# Main execution
if __name__ == "__main__":
    try:
        # Example usage with the email from your data
        user_email = "yunqi0729@gmail.com"
        user_data = get_user_data(user_email)
        display_user_data(user_data)
    except Exception as e:
        print(f"Error in main execution: {str(e)}")