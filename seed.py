"""Compatibility entry point. Seed implementation lives in backend.seed."""
from backend.seed import *

if __name__ == "__main__":
    from backend.app import app, db
    from backend.seed import ensure_demo_data, ensure_reference_data
    with app.app_context():
        db.create_all()
        ensure_reference_data()
        ensure_demo_data()
        print("Database initialized and seeded successfully.")
