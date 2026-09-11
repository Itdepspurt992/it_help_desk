from backend.app import Ticket, TicketComment, TicketHistory, AuditLog, Rating, Status, User, app, db
from tests.conftest import login


def create_ticket(client, **extra):
    data = {'title': 'Network problem', 'description': 'No network access', 'department_id': 4, 'category_id': 3, 'priority_id': 3}
    data.update(extra)
    return client.post('/tickets/new', data=data, follow_redirects=True)


def test_login_and_bad_login(client):
    r = login(client, 'admin', 'Admin@123')
    assert r.status_code == 200
    assert 'لوحة تحكم الدعم الفني'.encode() in r.data
    client.post('/logout')
    assert 'بيانات الدخول غير صحيحة'.encode() in client.post('/login', data={'username':'admin','password':'bad'}).data


def test_unauthorized_and_rbac(client):
    assert client.get('/settings').status_code == 302
    login(client, 'member', 'Member@123')
    assert client.get('/audit').status_code == 403
    assert client.get('/users').status_code == 403
    assert client.get('/assets').status_code == 403


def test_create_ticket_number_history_audit(client):
    login(client, 'member', 'Member@123')
    r = create_ticket(client)
    assert r.status_code == 200
    with app.app_context():
        t = Ticket.query.one()
        assert t.ticket_number == 'IT-000001'
        assert TicketHistory.query.filter_by(ticket_id=t.id, action='CREATED').count() == 1
        assert AuditLog.query.filter_by(action='CREATE_TICKET', entity_id=str(t.id)).count() == 1


def test_department_member_scope(client):
    login(client, 'member', 'Member@123')
    r = create_ticket(client)
    assert r.status_code == 200
    client.post('/logout'); login(client, 'member2', 'Member2@123')
    assert client.get('/tickets/1').status_code == 403
    assert client.get('/api/tickets').get_json() == []


def test_assignment_workflow_comments_resolution_rating_and_reopen(client):
    login(client, 'member', 'Member@123'); create_ticket(client); client.post('/logout')
    login(client, 'manager', 'Manager@123')
    assert client.post('/tickets/1/assign', data={'technician_id': 3}).status_code == 302
    client.post('/logout'); login(client, 'tech', 'Tech@123')
    assert client.post('/tickets/1/status', data={'status':'IN PROGRESS'}).status_code == 302
    assert client.post('/tickets/1/comment', data={'comment':'Checked cable and TCP/IP'}).status_code == 302
    assert client.post('/tickets/1/resolve', data={'resolution':'Reset network settings and renewed IP.'}).status_code == 302
    client.post('/logout'); login(client, 'member', 'Member@123')
    assert client.post('/tickets/1/rate', data={'score':5,'comment':'Excellent service'}).status_code == 302
    with app.app_context():
        t = Ticket.query.one()
        assert t.status.code == 'RESOLVED'
        assert TicketComment.query.count() == 1
        assert Rating.query.one().score == 5
        assert AuditLog.query.filter_by(action='RESOLVE_TICKET').count() == 1
    client.post('/logout'); login(client, 'manager', 'Manager@123')
    assert client.post('/tickets/1/status', data={'status':'CLOSED'}).status_code == 302
    assert client.post('/tickets/1/status', data={'status':'REOPENED'}).status_code == 302
    with app.app_context(): assert Ticket.query.one().status.code == 'REOPENED'


def test_requester_can_reopen_closed_ticket(client):
    login(client, 'member', 'Member@123'); create_ticket(client); client.post('/logout')
    login(client, 'manager', 'Manager@123'); client.post('/tickets/1/assign', data={'technician_id': 3}); client.post('/logout')
    login(client, 'tech', 'Tech@123'); client.post('/tickets/1/status', data={'status':'IN PROGRESS'}); client.post('/tickets/1/resolve', data={'resolution':'fixed'}); client.post('/tickets/1/status', data={'status':'CLOSED'}); client.post('/logout')
    login(client, 'member', 'Member@123'); assert client.post('/tickets/1/status', data={'status':'REOPENED'}).status_code == 302
    with app.app_context(): assert Ticket.query.one().status.code == 'REOPENED'


def test_invalid_transition_forbidden(client):
    login(client, 'member', 'Member@123'); create_ticket(client); client.post('/logout')
    login(client, 'tech', 'Tech@123')
    assert client.post('/tickets/1/status', data={'status':'RESOLVED'}).status_code == 302
    with app.app_context(): assert Ticket.query.one().status.code == 'NEW'


def test_api_ticket_lifecycle(client):
    login(client, 'member', 'Member@123')
    r = client.post('/api/tickets', json={'title':'API','description':'test','department_id':4,'category_id':3,'priority_id':1})
    assert r.status_code == 201 and r.json['ticket_number'] == 'IT-000001'
    assert client.get('/api/tickets/1').status_code == 200
    client.post('/logout'); login(client, 'manager', 'Manager@123')
    assert client.post('/api/tickets/1/assign', json={'technician_id':3}).status_code == 200
    client.post('/logout'); login(client, 'tech', 'Tech@123')
    assert client.post('/api/tickets/1/status', json={'status':'IN PROGRESS'}).status_code == 200
    assert client.post('/api/tickets/1/comments', json={'comment':'API comment'}).status_code == 200
    assert client.post('/api/tickets/1/resolve', json={'resolution':'API resolution'}).status_code == 200


def test_dashboard_reports_audit_notifications(client):
    login(client, 'member', 'Member@123'); create_ticket(client); client.post('/logout')
    login(client, 'admin', 'Admin@123')
    assert client.get('/').status_code == 200
    assert client.get('/reports').status_code == 200
    assert client.get('/reports/export.csv').status_code == 200
    assert client.get('/audit').status_code == 200
    assert client.get('/notifications').status_code == 200
    assert client.get('/api/reports/dashboard').status_code == 200
    assert client.get('/api/reports/monthly').status_code == 200
    assert client.get('/api/reports/technicians').status_code == 200


def test_password_is_hashed(client):
    with app.app_context():
        u = User.query.filter_by(username='admin').first()
        assert u.password_hash != 'Admin@123'
        assert u.check_password('Admin@123')


def test_api_csrf_endpoint(client):
    login(client, 'admin', 'Admin@123')
    r = client.get('/api/csrf-token')
    assert r.status_code == 200 and 'csrf_token' in r.json


def test_executive_is_read_only_and_cannot_browse_tickets(client):
    login(client, 'exec', 'Exec@123')
    assert client.get('/').status_code == 200
    assert client.get('/tickets').status_code == 403
    assert client.get('/api/tickets').status_code == 403
    assert client.get('/reports').status_code == 403
    assert client.get('/users').status_code == 403
    assert client.get('/settings').status_code == 403


def test_invalid_search_dates_return_400(client):
    login(client, 'admin', 'Admin@123')
    assert client.get('/tickets?date_from=not-a-date').status_code == 400


def test_api_invalid_rating_returns_400(client):
    login(client, 'member', 'Member@123'); create_ticket(client)
    assert client.post('/api/tickets/1/rate', json={'score':'bad'}).status_code == 400
