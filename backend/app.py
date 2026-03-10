from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/submit", methods=["POST"])
def submit():
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data received"}), 400

    name = data.get("name", "").strip()
    student_id = data.get("student_id", "").strip()
    email = data.get("email", "").strip()
    course = data.get("course", "").strip()
    grade = data.get("grade", "").strip()

    # Basic validation
    errors = []
    if not name:
        errors.append("Name is required.")
    if not student_id:
        errors.append("Student ID is required.")
    if not email or "@" not in email:
        errors.append("A valid email is required.")
    if not course:
        errors.append("Course is required.")
    if not grade:
        errors.append("Grade is required.")

    if errors:
        return jsonify({"success": False, "errors": errors}), 422

    # Determine grade status
    grade_map = {
        "A": "Excellent",
        "B": "Good",
        "C": "Average",
        "D": "Below Average",
        "F": "Fail",
    }
    grade_status = grade_map.get(grade.upper(), "Unknown")

    response = {
        "success": True,
        "message": f"Student '{name}' submitted successfully!",
        "data": {
            "name": name,
            "student_id": student_id,
            "email": email,
            "course": course,
            "grade": grade.upper(),
            "grade_status": grade_status,
        },
    }

    return jsonify(response), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
