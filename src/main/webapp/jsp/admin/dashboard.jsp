<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Timesheet System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; min-height: 100vh; }
        .navbar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 1.5rem; }
        .navbar .user-info { display: flex; align-items: center; gap: 1rem; }
        .navbar .logout-btn { background: rgba(255,255,255,0.2); color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 5px; }
        .container { max-width: 1600px; margin: 0 auto; padding: 2rem; }
        .welcome-section { background: white; padding: 2rem; border-radius: 10px; margin-bottom: 2rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid; }
        .stat-card.primary { border-left-color: #667eea; }
        .stat-card.success { border-left-color: #4caf50; }
        .stat-card.warning { border-left-color: #ff9800; }
        .stat-card.danger { border-left-color: #f44336; }
        .stat-card.info { border-left-color: #2196f3; }
        .stat-card.purple { border-left-color: #9c27b0; }
        .stat-card h3 { color: #666; font-size: 0.85rem; margin-bottom: 0.5rem; }
        .stat-card .value { font-size: 1.8rem; font-weight: bold; color: #333; }
        .content-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 2rem; }
        .card { background: white; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 1rem 1.5rem; font-weight: 600; }
        .card-body { padding: 1.5rem; max-height: 350px; overflow-y: auto; }
        .list-item { padding: 0.8rem; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; }
        .list-item:last-child { border-bottom: none; }
        .item-name { font-weight: 500; color: #333; font-size: 0.9rem; }
        .item-info { font-size: 0.8rem; color: #666; }
        .badge { padding: 0.2rem 0.6rem; border-radius: 10px; font-size: 0.7rem; font-weight: 600; }
        .badge.active { background: #e8f5e9; color: #388e3c; }
        .badge.completed { background: #e3f2fd; color: #1976d2; }
        .badge.overdue { background: #ffebee; color: #c62828; }
        .badge.pending { background: #fff3e0; color: #f57c00; }
        .empty-state { text-align: center; padding: 2rem; color: #999; font-size: 0.9rem; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Timesheet System - Admin Dashboard</h1>
        <div class="user-info">
            <span>Welcome, ${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-section">
            <h2>System Administration</h2>
            <p>Overview of all projects, users, tasks and system activities</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card primary">
                <h3>Total Users</h3>
                <div class="value">${totalUsers}</div>
            </div>
            <div class="stat-card success">
                <h3>Total Projects</h3>
                <div class="value">${totalProjects}</div>
            </div>
            <div class="stat-card warning">
                <h3>Total Tasks</h3>
                <div class="value">${totalTasks}</div>
            </div>
            <div class="stat-card info">
                <h3>Active Projects</h3>
                <div class="value">${activeProjectCount}</div>
            </div>
            <div class="stat-card danger">
                <h3>Overdue Tasks</h3>
                <div class="value">${overdueTaskCount}</div>
            </div>
            <div class="stat-card purple">
                <h3>Pending Validations</h3>
                <div class="value">${pendingValidationCount}</div>
            </div>
        </div>

        <h3 style="margin-bottom: 1rem; color: #333;">User Statistics</h3>
        <div class="stats-grid" style="margin-bottom: 2rem;">
            <div class="stat-card primary">
                <h3>Administrators</h3>
                <div class="value">${adminCount}</div>
            </div>
            <div class="stat-card success">
                <h3>Project Managers</h3>
                <div class="value">${managerCount}</div>
            </div>
            <div class="stat-card info">
                <h3>Employees</h3>
                <div class="value">${employeeCount}</div>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header">All Projects</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty allProjects}">
                            <div class="empty-state">No projects in system</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${allProjects}" var="project" varStatus="status">
                                <c:if test="${status.index < 10}">
                                    <div class="list-item">
                                        <div>
                                            <div class="item-name">${project.name}</div>
                                            <div class="item-info">Manager: ${project.manager.fullName}</div>
                                        </div>
                                        <span class="badge ${project.status == 'ACTIVE' ? 'active' : project.status == 'COMPLETED' ? 'completed' : 'pending'}">
                                            ${project.status}
                                        </span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Overdue Tasks</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty overdueTasks}">
                            <div class="empty-state">No overdue tasks</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${overdueTasks}" var="task" varStatus="status">
                                <c:if test="${status.index < 10}">
                                    <div class="list-item">
                                        <div>
                                            <div class="item-name">${task.name}</div>
                                            <div class="item-info">${task.project.name} - ${task.assignedTo.fullName}</div>
                                        </div>
                                        <span class="badge overdue">OVERDUE</span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Pending Timesheet Validations</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty pendingTimesheets}">
                            <div class="empty-state">No pending timesheets</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${pendingTimesheets}" var="timesheet" varStatus="status">
                                <c:if test="${status.index < 10}">
                                    <div class="list-item">
                                        <div>
                                            <div class="item-name">${timesheet.user.fullName}</div>
                                            <div class="item-info">Week: ${timesheet.weekDescription} - ${timesheet.totalHours}h</div>
                                        </div>
                                        <span class="badge pending">PENDING</span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Unvalidated Projects</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty unvalidatedProjects}">
                            <div class="empty-state">No unvalidated projects</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${unvalidatedProjects}" var="project">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${project.name}</div>
                                        <div class="item-info">Manager: ${project.manager.fullName}</div>
                                    </div>
                                    <span class="badge pending">PENDING</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Over-Budget Projects</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty overBudgetProjects}">
                            <div class="empty-state">No over-budget projects</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${overBudgetProjects}" var="project">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${project.name}</div>
                                        <div class="item-info">Est: $${project.estimatedCost} | Actual: $${project.actualCost}</div>
                                    </div>
                                    <span class="badge overdue">OVER BUDGET</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Active Users</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty activeUsers}">
                            <div class="empty-state">No active users</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${activeUsers}" var="user" varStatus="status">
                                <c:if test="${status.index < 10}">
                                    <div class="list-item">
                                        <div>
                                            <div class="item-name">${user.fullName}</div>
                                            <div class="item-info">${user.email}</div>
                                        </div>
                                        <span class="badge ${user.role == 'ADMIN' ? 'danger' : user.role == 'PROJECT_MANAGER' ? 'warning' : 'info'}">
                                            ${user.role}
                                        </span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</body>
</html>