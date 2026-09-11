import pytest

from backend.app import (
    Category, Department, Permission, Priority, Role, RolePermission, Status, User,
    app, db, PERMISSIONS, ROLE_DEFAULTS, ROLE_NAMES, DEPARTMENTS, CATEGORIES, PRIORITIES, STATUSES,
)


@pytest.fixture()
def client(tmp_path):
    app.config.update(
        TESTING=True,
        SQLALCHEMY_DATABASE_URI=f"sqlite:///{tmp_path / 'test.db'}",
        WTF_CSRF_ENABLED=False,
        SECRET_KEY="test-secret",
        UPLOAD_FOLDER=str(tmp_path / "uploads"),
    )
    with app.app_context():
        db.drop_all(); db.create_all()
        for name in ROLE_NAMES: db.session.add(Role(name=name))
        for code, desc in PERMISSIONS.items(): db.session.add(Permission(code=code, description=desc))
        for name in DEPARTMENTS: db.session.add(Department(name=name, is_active=True))
        for name in CATEGORIES: db.session.add(Category(name=name, is_active=True))
        for code, name in STATUSES: db.session.add(Status(code=code, name=name, is_active=True))
        for name, level, sla in PRIORITIES: db.session.add(Priority(name=name, level=level, sla_minutes=sla))
        db.session.commit()
        for role_name, codes in ROLE_DEFAULTS.items():
            role = Role.query.filter_by(name=role_name).first()
            role.permissions = Permission.query.filter(Permission.code.in_(codes)).all()
        db.session.commit()
        def add_user(username, password, name, role_name, department_id):
            u = User(username=username, full_name=name, role_id=Role.query.filter_by(name=role_name).first().id, department_id=department_id)
            u.set_password(password); db.session.add(u); db.session.flush(); return u
        add_user("admin", "Admin@123", "Admin", "IT Administrator", 7)
        add_user("manager", "Manager@123", "Manager", "IT Manager", 7)
        add_user("tech", "Tech@123", "Tech", "IT Technician", 7)
        add_user("member", "Member@123", "Member", "Department Member", 4)
        add_user("member2", "Member2@123", "Member 2", "Department Member", 2)
        add_user("dm", "Dm@12345", "Department Manager", "Department Manager", 4)
        add_user("exec", "Exec@123", "Executive", "Executive Manager", 1)
        db.session.commit()
    yield app.test_client()
    with app.app_context(): db.session.remove()


def login(client, username, password):
    return client.post('/login', data={'username': username, 'password': password}, follow_redirects=True)
