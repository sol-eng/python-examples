import email
from app import db, User

db.create_all()
db.session.add(User(username="Flask", email="flask@example.com"))
db.session.commit()
