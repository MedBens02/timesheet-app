<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard - Timesheet System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; min-height: 100vh; }
        .navbar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 1.5rem; }
        .navbar .user-info { display: flex; align-items: center; gap: 1rem; }
        .navbar .logout-btn { background: rgba(255,255,255,0.2); color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 5px; }
        .container { max-width: 1400px; margin: 0 auto; padding: 2rem; }
        .welcome-section { background: white; padding: 2rem; border-radius: 10px; margin-bottom: 2rem; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid; }
        .stat-card.primary { border-left-color: #667eea; }
        .stat-card.success { border-left-color: #4caf50; }
        .stat-card.warning { border-left-color: #ff9800; }
        .stat-card.danger { border-left-color: #f44336; }
        .stat-card.info { border-left-color: #2196f3; }
        .stat-card h3 { color: #666; font-size: 0.9rem; margin-bottom: 0.5rem; }
        .stat-card .value { font-size: 2rem; font-weight: bold; color: #333; }
        .content-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(450px, 1fr)); gap: 2rem; }
        .card { background: white; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 1rem 1.5rem; font-weight: 600; }
        .card-body { padding: 1.5rem; max-height: 400px; overflow-y: auto; }
        .list-item { padding: 1rem; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; }
        .list-item:last-child { border-bottom: none; }
        .item-name { font-weight: 500; color: #333; }
        .item-info { font-size: 0.85rem; color: #666; }
        .badge { padding: 0.25rem 0.75rem; border-radius: 12px; font-size: 0.75rem; font-weight: 600; }
        .badge.active { background: #e8f5e9; color: #388e3c; }
        .badge.completed { background: #e3f2fd; color: #1976d2; }
        .badge.overdue { background: #ffebee; color: #c62828; }
        .badge.high { background: #ffebee; color: #c62828; }
        .badge.pending { background: #fff3e0; color: #f57c00; }
        .empty-state { text-align: center; padding: 2rem; color: #999; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Timesheet System - Manager Dashboard</h1>
        <div class="user-info">
            <span>Welcome, ${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-section">
            <h2>Manager Dashboard</h2>
            <p>Manage your projects, teams, and approve timesheets</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card primary">
                <h3>Total Projects</h3>
                <div class="value">${totalProjects}</div>
            </div>
            <div class="stat-card success">
                <h3>Active Projects</h3>
                <div class="value">${activeProjectCount}</div>
            </div>
            <div class="stat-card warning">
                <h3>Total Tasks</h3>
                <div class="value">${totalTasks}</div>
            </div>
            <div class="stat-card danger">
                <h3>Overdue Tasks</h3>
                <div class="value">${overdueTaskCount}</div>
            </div>
            <div class="stat-card info">
                <h3>Pending Validations</h3>
                <div class="value">${pendingValidations}</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <h3 style="margin-bottom: 1rem; color: #333;">Quick Actions</h3>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/project/create" style="padding: 10px 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">+ Create Project</a>
                <a href="${pageContext.request.contextPath}/project/list" style="padding: 10px 20px; background: #17a2b8; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">📁 My Projects</a>
                <a href="#" style="padding: 10px 20px; background: #28a745; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">📋 Manage Tasks</a>
                <a href="#" style="padding: 10px 20px; background: #ffc107; color: #333; border-radius: 6px; text-decoration: none; font-weight: 500;">✓ Validate Timesheets</a>
                <a href="${pageContext.request.contextPath}/logout" style="padding: 10px 20px; background: #6c757d; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">🚪 Logout</a>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header">My Projects</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty myProjects}">
                            <div class="empty-state">No projects assigned</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${myProjects}" var="project">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${project.name}</div>
                                        <div class="item-info">${project.estimatedHours} estimated hours</div>
                                    </div>
                                    <span class="badge ${project.status == 'ACTIF' ? 'active' : project.status == 'TERMINE' ? 'completed' : 'pending'}">
                                        ${project.status}
                                    </span>
                                </div>
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
                            <c:forEach items="${overdueTasks}" var="task">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${task.name}</div>
                                        <div class="item-info">${task.project.name} - Assigned to: ${task.assignedTo.fullName}</div>
                                    </div>
                                    <span class="badge overdue">OVERDUE</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">High Priority Tasks</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty highPriorityTasks}">
                            <div class="empty-state">No high priority tasks</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${highPriorityTasks}" var="task">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${task.name}</div>
                                        <div class="item-info">${task.project.name}</div>
                                    </div>
                                    <span class="badge high">${task.priority}</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Timesheets Awaiting Validation</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty timesheetsForValidation}">
                            <div class="empty-state">No pending timesheets</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${timesheetsForValidation}" var="timesheet">
                                <div class="list-item">
                                    <div>
                                        <div class="item-name">${timesheet.user.fullName}</div>
                                        <div class="item-info">
                                            <fmt:formatDate value="${timesheet.weekStartDate}" pattern="MMM dd"/> -
                                            <fmt:formatDate value="${timesheet.weekEndDate}" pattern="MMM dd, yyyy"/>
                                            (${timesheet.totalHours}h)
                                        </div>
                                    </div>
                                    <span class="badge pending">PENDING</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</body>
</html>