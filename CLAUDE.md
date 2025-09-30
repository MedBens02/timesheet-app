# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**JEE Timesheet Management Application** - A comprehensive enterprise web application for managing projects, tasks, and employee timesheets with role-based access control and automated pay calculation.

## Technology Stack

- **Language**: Java 17
- **Framework**: Jakarta EE (JEE) with Servlets/JSP
- **ORM**: Hibernate 6.3.1 with JPA
- **Database**: MySQL 8.x (timesheet_db)
- **Server**: Apache Tomcat 10.1
- **Build**: Maven 3.x
- **IDE**: IntelliJ IDEA

## Database Configuration

- **Database**: `timesheet_db` (created via src/main/resources/database-schema.sql)
- **Connection**: root user, localhost:3306
- **Test Users**:
  - admin / admin123 (ADMIN role)
  - jsmith / manager123 (PROJECT_MANAGER role) 
  - mjohnson / employee123 (EMPLOYEE role)

## Development Commands

**Build and Package:**
```bash
mvn clean compile
mvn package
```

**Deploy to Tomcat:**
```bash
# Copy target/timesheet-app.war to:
# C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\
```

**Access Application:**
```
http://localhost:8080/timesheet-app/
```

## Project Structure

```
JiraClone/
├── src/main/
│   ├── java/com/timesheetapp/
│   │   ├── entity/          # JPA entities (User, Project, Task, Timesheet, TimesheetEntry)
│   │   ├── dao/             # Data Access Objects [IN PROGRESS]
│   │   ├── service/         # EJB business logic [PENDING]
│   │   ├── controller/      # Servlet controllers [PENDING]
│   │   ├── util/            # Utility classes [PENDING]
│   │   └── Main.java        # Test main class
│   ├── resources/
│   │   ├── META-INF/
│   │   │   └── persistence.xml  # JPA configuration
│   │   └── database-schema.sql  # Database creation script
│   └── webapp/
│       ├── WEB-INF/
│       │   └── web.xml      # Servlet configuration
│       ├── jsp/             # JSP pages [PENDING]
│       ├── css/             # Stylesheets [PENDING]
│       ├── js/              # JavaScript [PENDING]
│       └── index.jsp        # Welcome page
├── target/                  # Maven build output
├── pom.xml                  # Maven dependencies
└── CLAUDE.md               # This file
```

## Application Architecture

**3-Tier Enterprise Architecture:**

1. **Presentation Layer**: JSP pages + Servlets
2. **Business Logic Layer**: EJB Session Beans
3. **Data Access Layer**: JPA Entities + DAOs

## Key Features

### User Management
- Role-based access: Employee, Project Manager, Admin
- Authentication and session management
- Password hashing with BCrypt

### Project Management
- Project creation with cost/hour estimation
- Task assignment to employees
- Project validation workflow
- Progress tracking

### Timesheet Management
- Weekly timesheet entry by task
- Automatic overtime calculation (1.25x for >40h/week)
- Validation workflow (Submit → Validate → Approve/Reject)
- Pay calculation (regular + overtime)

### Reporting & Analytics
- Employee hours and salary tracking
- Project progress and cost analysis
- Manager oversight and validation

## Entity Relationships

- **User** 1:N **Project** (as manager)
- **User** 1:N **Task** (assigned to)
- **User** 1:N **Timesheet**
- **Project** 1:N **Task**
- **Timesheet** 1:N **TimesheetEntry**
- **Task** 1:N **TimesheetEntry**

## Current Development Status

### ✅ **COMPLETED TASKS:**

**1. Project Infrastructure & Build:**
- ✅ Maven project structure with proper package hierarchy
- ✅ Complete pom.xml with JEE, Hibernate 6.3.1, MySQL dependencies
- ✅ Fixed Maven dependency issue (removed obsolete hibernate-entitymanager)
- ✅ Successful Maven build: `mvn clean compile` and `mvn package` work
- ✅ WAR file creation: `target/timesheet-app.war` ready for deployment

**2. Database & Configuration:**
- ✅ MySQL database `timesheet_db` created via database-schema.sql
- ✅ 5 tables: users, projects, tasks, timesheets, timesheet_entries
- ✅ Sample data with test users (passwords fixed with proper BCrypt hashes):
  - admin / admin123 (ADMIN role)
  - jsmith / manager123 (PROJECT_MANAGER role)
  - mjohnson / employee123 (EMPLOYEE role)
- ✅ persistence.xml configured with **hibernate.hbm2ddl.auto=update** (preserves data)
- ✅ web.xml cleaned up - uses @WebServlet annotations instead of XML declarations
- ✅ fix-is-active.sql - quick fix for null is_active fields

**3. Data Model (JPA Entities):**
- ✅ User.java - with roles, password hashing, audit fields
- ✅ Project.java - with validation workflow, cost tracking
- ✅ Task.java - with priorities, assignments, progress tracking
- ✅ Timesheet.java - with weekly tracking, overtime calculation (1.25x)
- ✅ TimesheetEntry.java - with daily hour logging, validation

**4. Data Access Layer (Complete DAO Implementation with Eager Fetching):**
- ✅ BaseDAO.java + BaseDAOImpl.java - common CRUD operations
- ✅ UserDAO.java + UserDAOImpl.java - user queries by role, username, email
- ✅ ProjectDAO.java + ProjectDAOImpl.java - **ALL queries use JOIN FETCH for manager** (fixes LazyInitializationException)
- ✅ TaskDAO.java + TaskDAOImpl.java - **ALL queries use JOIN FETCH for project + assignedTo** (fixes LazyInitializationException)
- ✅ TimesheetDAO.java + TimesheetDAOImpl.java - timesheet queries by user, week
- ✅ TimesheetEntryDAO.java + TimesheetEntryDAOImpl.java - entry queries by timesheet, task, date
- ✅ EntityManagerUtil.java - JPA EntityManager factory management

**5. Business Logic Layer (EJB Session Beans):**
- ✅ UserService.java - authentication, user management, password operations
- ✅ ProjectService.java - project CRUD, validation workflow, progress tracking
- ✅ TaskService.java - task assignment, status management, progress tracking
- ✅ TimesheetService.java - timesheet calculation, validation workflow, overtime pay

**6. Utility Classes:**
- ✅ PasswordUtil.java - BCrypt hashing, password validation, temp password generation
- ✅ ValidationUtil.java - input validation, business rules, date utilities
- ✅ SessionUtil.java - session management, user authentication helpers

**7. Authentication & Security:**
- ✅ LoginServlet.java - login/logout handling, session creation
- ✅ AuthenticationFilter.java - role-based access control, URL protection
- ✅ login.jsp - professional login page with demo credentials

**8. Web Structure:**
- ✅ webapp directory with WEB-INF, jsp folders (admin, employee, manager)
- ✅ index.jsp welcome page with login link
- ✅ CSS and JS directories created (empty)

### 🚧 **NEXT DEVELOPMENT PHASE:**

**IMMEDIATE NEXT TASKS (in order):**
1. **Main Servlets:** DashboardServlet, ProjectServlet, TaskServlet, TimesheetServlet
2. **Complete JSP Pages:** dashboard, project management, timesheet entry
3. **CSS Styling:** Professional enterprise appearance
4. **Testing & Deployment:** Full application testing

### 📋 **DETAILED TODO CHECKLIST:**

#### Phase 1: Complete Data Layer ✅ COMPLETED
- [x] Finish TimesheetEntryDAOImpl.java implementation
- [x] Test DAO layer with simple main class

#### Phase 2: Business Logic Layer (EJB Session Beans) ✅ COMPLETED
- [x] Create UserService.java - authentication, user management
- [x] Create ProjectService.java - project CRUD, validation workflow
- [x] Create TaskService.java - task assignment, progress tracking
- [x] Create TimesheetService.java - timesheet calculation, validation

#### Phase 3: Authentication & Security ✅ COMPLETED
- [x] Create LoginServlet.java - handles login/logout
- [x] Create SessionUtil.java - session management utilities
- [x] Create AuthenticationFilter.java - protect secured pages
- [x] Create login.jsp - login form with validation

#### Phase 4: Main Application Controllers ✅ PARTIALLY COMPLETED
- [x] Create DashboardServlet.java - role-based dashboard (COMPLETED)
- [ ] Create ProjectServlet.java - project CRUD operations
- [ ] Create TaskServlet.java - task CRUD operations
- [ ] Create TimesheetServlet.java - timesheet entry/validation

#### Phase 5: User Interface (JSP Pages) ✅ PARTIALLY COMPLETED
- [x] Create dashboard.jsp - three role-based views (admin, manager, employee) with modern gradient design
- [ ] Create project-list.jsp, project-form.jsp - project management UI
- [ ] Create task-list.jsp, task-form.jsp - task management UI
- [ ] Create timesheet-entry.jsp, timesheet-list.jsp - timesheet entry UI
- [ ] Create admin pages for user management

#### Phase 6: Styling & Polish
- [ ] Create style.css - professional enterprise styling
- [ ] Add JavaScript for form validation, calendar widgets
- [ ] Create error pages (404.jsp, 500.jsp)
- [ ] Add responsive design for mobile/tablet

#### Phase 7: Testing & Deployment
- [ ] Unit tests for services and DAOs
- [ ] Integration testing with full workflow
- [ ] Deploy to Tomcat and test all features
- [ ] Performance testing and optimization

### 🎯 **APPLICATION ARCHITECTURE READY:**
- **3-Tier Enterprise Architecture:** Presentation → Business → Data
- **Role-Based Access Control:** Employee, Project Manager, Admin
- **Key Features:** Project management, task assignment, timesheet tracking, overtime pay (1.25x), validation workflow
- **Technology Stack:** Java 17, Jakarta EE, Hibernate 6, MySQL, Tomcat 10.1, Maven

### 📁 **FILE LOCATIONS FOR REFERENCE:**
```
src/main/java/com/timesheetapp/
├── entity/          # ✅ Complete: User, Project, Task, Timesheet, TimesheetEntry
├── dao/             # ✅ Complete: All interfaces and implementations
├── dao/impl/        # ✅ Complete: All 5 DAO implementations
├── service/         # ✅ Complete: UserService, ProjectService, TaskService, TimesheetService
├── controller/      # ✅ In Progress: LoginServlet, AuthenticationFilter complete
├── util/            # ✅ Complete: EntityManagerUtil, PasswordUtil, ValidationUtil, SessionUtil
└── Main.java        # Test class

src/main/webapp/
├── index.jsp        # ✅ Welcome page complete
├── jsp/
│   └── login.jsp    # ✅ Professional login page
├── css/             # ⏳ Pending: Main stylesheet
└── js/              # ⏳ Pending: JavaScript
```

## Development Notes

- **Maven Build:** Working perfectly, WAR file ready for deployment
- **Database:** timesheet_db created and populated with test data
- **Authentication:** Uses BCrypt for password hashing  
- **Overtime Calculation:** 1.25x rate for hours > 40/week
- **Session Management:** Ready for servlet-based authentication
- **Validation:** Comprehensive input validation utilities ready
- **Error Handling:** DAO layer has proper exception handling

## Next Session Commands:

### To Start Development Session:
```bash
# 1. Ensure database is running and has correct data
mysql -u root -p < src/main/resources/fix-is-active.sql

# 2. Build and deploy
cd C:\Users\PC\Desktop\JEE\JiraClone
mvn clean package
cp target/timesheet-app.war "C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\"

# 3. Access application
# http://localhost:8080/timesheet-app/login
# Credentials: admin/admin123, jsmith/manager123, mjohnson/employee123
```

### Phase 5: Next Development Tasks (Priority Order):
1. **ProjectServlet + JSP** - CRUD operations for project management (create, list, edit, delete, validate)
2. **TaskServlet + JSP** - CRUD operations for task management (assign, update status, set priority)
3. **TimesheetServlet + JSP** - Weekly timesheet entry, submission, validation workflow
4. **User Management Pages** - Admin pages for creating/editing users (admin only)
5. **Reporting** - Generate reports for hours worked, project costs, employee productivity

## Latest Session Completed (2025-09-30):

### Session 1: Core Development
- ✅ Phase 1: Completed TimesheetEntryDAOImpl.java
- ✅ Phase 2: Completed all 4 service beans (UserService, ProjectService, TaskService, TimesheetService)
- ✅ Phase 3: Completed authentication system
  - SessionUtil.java for session management
  - LoginServlet.java for login/logout with role-based redirects
  - AuthenticationFilter.java for URL protection and role-based access control
  - login.jsp with modern gradient design and demo credentials
- ✅ Phase 4: Completed dashboard system
  - DashboardServlet with role-based logic (admin, manager, employee)
  - Employee dashboard JSP (tasks, timesheets, statistics)
  - Manager dashboard JSP (projects, validations, team oversight)
  - Admin dashboard JSP (system-wide overview, 6 stats cards, 6 info sections)
- ✅ Successful Maven build: `mvn clean compile` and `mvn package`
- ✅ WAR file created: target/timesheet-app.war (30 source files compiled)

### Session 2: Bug Fixes & Production Deployment
- ✅ **Fixed Hibernate create-drop issue** - Changed persistence.xml from `create-drop` to `update` (line 27)
- ✅ **Fixed web.xml servlet conflicts** - Removed duplicate servlet declarations, now using @WebServlet annotations
- ✅ **Fixed password authentication NullPointerException:**
  - Root cause: `is_active` column was NULL in database
  - Fix 1: Made UserService.authenticate() null-safe (line 35)
  - Fix 2: Updated database-schema.sql to include `is_active = TRUE` in INSERTs
  - Fix 3: Created fix-is-active.sql for quick database repair
  - Fix 4: Generated proper BCrypt hashes with PasswordHashGenerator.java
  - Fix 5: Created update-passwords.sql with correct password hashes
- ✅ **Fixed Hibernate LazyInitializationException:**
  - Root cause: Hibernate session closed before JSP accessed lazy-loaded entities
  - Fix: Added `JOIN FETCH` to ALL ProjectDAO queries (fetches manager eagerly)
  - Fix: Added `JOIN FETCH` to ALL TaskDAO queries (fetches project + assignedTo eagerly)
  - Impact: Eliminates "could not initialize proxy - no Session" errors in JSP pages
- ✅ **Deployed to Tomcat 10.1** - Application running on http://localhost:8080/timesheet-app/
- ✅ **Login working** with credentials: admin/admin123, jsmith/manager123, mjohnson/employee123
- ✅ **Dashboards working** - All three role-based dashboards displaying correctly

### Critical Fixes Applied:
1. **persistence.xml:27** - `hibernate.hbm2ddl.auto = update` (was: create-drop)
2. **UserService.java:35** - Null-safe check: `if (user.getIsActive() == null || !user.getIsActive())`
3. **ProjectDAOImpl.java** - All methods use `JOIN FETCH p.manager`
4. **TaskDAOImpl.java** - All methods use `JOIN FETCH t.project JOIN FETCH t.assignedTo`
5. **database-schema.sql:135-144** - All user INSERTs now include `is_active = TRUE`

### Known Issues Resolved:
- ❌ Database wiped on restart → ✅ FIXED (hibernate.hbm2ddl.auto = update)
- ❌ Login fails with "User account inactive" → ✅ FIXED (null-safe check + SQL fix)
- ❌ Dashboard shows LazyInitializationException → ✅ FIXED (JOIN FETCH in DAOs)
- ❌ 404 errors on dashboard access → ✅ FIXED (cleaned web.xml conflicts)

### Application Status: **FULLY FUNCTIONAL** ✅
- Login page works correctly with role-based authentication
- Admin dashboard shows 6 statistics + 6 information sections
- Manager dashboard shows projects, tasks, and pending validations
- Employee dashboard shows tasks, timesheets, and statistics
- All dashboards render without LazyInitializationException errors