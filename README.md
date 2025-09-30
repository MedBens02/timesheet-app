# JEE Timesheet Management Application

A comprehensive enterprise web application for managing projects, tasks, and employee timesheets with role-based access control and automated pay calculation.

## 🚀 Quick Start

### Prerequisites
- Java 17 or higher
- Apache Maven 3.x
- MySQL 8.x
- Apache Tomcat 10.1

### Installation

1. **Create Database:**
```bash
mysql -u root -p < src/main/resources/database-schema.sql
mysql -u root -p < src/main/resources/update-passwords.sql
mysql -u root -p < src/main/resources/fix-is-active.sql
```

2. **Build Application:**
```bash
mvn clean package
```

3. **Deploy to Tomcat:**
```bash
cp target/timesheet-app.war /path/to/tomcat/webapps/
```

4. **Access Application:**
```
http://localhost:8080/timesheet-app/login
```

## 🔐 Demo Credentials

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| jsmith | manager123 | PROJECT_MANAGER |
| mjohnson | employee123 | EMPLOYEE |

## 📋 Features

### Current Features (v1.0)
- ✅ User authentication with BCrypt password hashing
- ✅ Role-based access control (Admin, Manager, Employee)
- ✅ Admin dashboard (system-wide statistics)
- ✅ Manager dashboard (project oversight)
- ✅ Employee dashboard (tasks and timesheets)
- ✅ Session management
- ✅ Automated overtime calculation (1.25x for >40h/week)

### Upcoming Features
- 🔄 Project CRUD operations
- 🔄 Task management system
- 🔄 Timesheet entry interface
- 🔄 User management (admin)
- 🔄 Reporting and analytics

## 🏗️ Architecture

**Technology Stack:**
- Java 17
- Jakarta EE (Servlets/JSP)
- Hibernate 6.3.1 (JPA)
- MySQL 8.x
- Apache Tomcat 10.1
- Maven 3.x

**3-Tier Architecture:**
```
Presentation Layer (JSP)
        ↓
Controller Layer (Servlets)
        ↓
Business Logic (EJB Services)
        ↓
Data Access Layer (DAOs)
        ↓
Database (MySQL)
```

## 📁 Project Structure

```
src/
├── main/
│   ├── java/com/timesheetapp/
│   │   ├── entity/          # JPA Entities
│   │   ├── dao/             # Data Access Objects
│   │   ├── service/         # Business Logic
│   │   ├── controller/      # Servlets
│   │   └── util/            # Utilities
│   ├── resources/
│   │   └── META-INF/
│   │       └── persistence.xml
│   └── webapp/
│       ├── WEB-INF/
│       │   └── web.xml
│       └── jsp/             # JSP Pages
└── test/                    # Unit Tests
```

## 📖 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Complete development history and technical details
- **[DEPLOYMENT-STATUS.md](DEPLOYMENT-STATUS.md)** - Deployment guide and current status

## 🛠️ Development

### Build Commands
```bash
# Compile only
mvn clean compile

# Package WAR file
mvn clean package

# Run tests
mvn test
```

### Database Scripts
- `database-schema.sql` - Create tables and sample data
- `update-passwords.sql` - Fix password hashes
- `fix-is-active.sql` - Fix user active status

## 🐛 Known Issues

See [DEPLOYMENT-STATUS.md](DEPLOYMENT-STATUS.md) for complete list of known issues and limitations.

## 📝 License

Educational project - Free to use and modify

## 👥 Contributors

Developed with assistance from Claude AI (Anthropic)

## 📞 Support

For issues and questions, please refer to the documentation files.

---

**Status:** ✅ Production Ready (v1.0)
**Last Updated:** September 30, 2025
