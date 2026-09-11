"""Compatibility entry point. Production code lives in backend.app."""
from backend.app import *

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host=os.getenv("HOST", "0.0.0.0"), port=int(os.getenv("PORT", "5000")), debug=False)
