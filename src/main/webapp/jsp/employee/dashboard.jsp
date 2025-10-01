<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Dashboard - Timesheet System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f7fa;
            min-height: 100vh;
        }

        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .navbar h1 {
            font-size: 1.5rem;
        }

        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .navbar .logout-btn {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 0.5rem 1rem;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }

        .navbar .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        .welcome-section {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .welcome-section h2 {
            color: #333;
            margin-bottom: 0.5rem;
        }

        .welcome-section p {
            color: #666;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid;
        }

        .stat-card.primary { border-left-color: #667eea; }
        .stat-card.success { border-left-color: #4caf50; }
        .stat-card.warning { border-left-color: #ff9800; }
        .stat-card.danger { border-left-color: #f44336; }

        .stat-card h3 {
            color: #666;
            font-size: 0.9rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .stat-card .value {
            font-size: 2rem;
            font-weight: bold;
            color: #333;
        }

        .content-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 2rem;
        }

        .card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 1.5rem;
            font-weight: 600;
        }

        .card-body {
            padding: 1.5rem;
        }

        .task-list {
            list-style: none;
        }

        .task-item {
            padding: 1rem;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .task-item:last-child {
            border-bottom: none;
        }

        .task-name {
            font-weight: 500;
            color: #333;
            margin-bottom: 0.25rem;
        }

        .task-project {
            font-size: 0.85rem;
            color: #666;
        }

        .badge {
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge.todo { background: #e3f2fd; color: #1976d2; }
        .badge.in-progress { background: #fff3e0; color: #f57c00; }
        .badge.completed { background: #e8f5e9; color: #388e3c; }
        .badge.high { background: #ffebee; color: #c62828; }
        .badge.medium { background: #fff3e0; color: #f57c00; }
        .badge.low { background: #e0e0e0; color: #616161; }

        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #999;
        }

        .empty-state svg {
            width: 64px;
            height: 64px;
            margin-bottom: 1rem;
            opacity: 0.3;
        }

        .btn {
            display: inline-block;
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: transform 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
        }

        .timesheet-status {
            padding: 0.5rem 1rem;
            border-radius: 5px;
            font-weight: 600;
            text-align: center;
        }

        .timesheet-status.draft { background: #e0e0e0; color: #616161; }
        .timesheet-status.submitted { background: #fff3e0; color: #f57c00; }
        .timesheet-status.validated { background: #e8f5e9; color: #388e3c; }
        .timesheet-status.rejected { background: #ffebee; color: #c62828; }
    </style>
</head>
<body>
    <nav class="navbar">
        <h1>Timesheet System - Employee Dashboard</h1>
        <div class="user-info">
            <span>Welcome, ${sessionScope.currentUser.firstName} ${sessionScope.currentUser.lastName}</span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="welcome-section">
            <h2>Welcome back, ${sessionScope.currentUser.firstName}!</h2>
            <p>Here's your activity summary and pending tasks</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card primary">
                <h3>Total Tasks</h3>
                <div class="value">${totalTasks}</div>
            </div>
            <div class="stat-card success">
                <h3>Completed</h3>
                <div class="value">${completedTasks}</div>
            </div>
            <div class="stat-card warning">
                <h3>In Progress</h3>
                <div class="value">${inProgressTasks}</div>
            </div>
            <div class="stat-card danger">
                <h3>Overdue</h3>
                <div class="value">${overdueCount}</div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <h3 style="margin-bottom: 1rem; color: #333;">Quick Actions</h3>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/project/list" style="padding: 10px 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">📁 My Projects</a>
                <a href="#" style="padding: 10px 20px; background: #28a745; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">📋 My Tasks</a>
                <a href="#" style="padding: 10px 20px; background: #17a2b8; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">⏱️ Register Hours</a>
                <a href="#" style="padding: 10px 20px; background: #ffc107; color: #333; border-radius: 6px; text-decoration: none; font-weight: 500;">📊 Timesheet History</a>
                <a href="${pageContext.request.contextPath}/logout" style="padding: 10px 20px; background: #6c757d; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">🚪 Logout</a>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header">My Active Tasks</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty myTasks}">
                            <div class="empty-state">
                                <p>No active tasks assigned</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="task-list">
                                <c:forEach items="${myTasks}" var="task" varStatus="status">
                                    <c:if test="${status.index < 5}">
                                        <li class="task-item">
                                            <div>
                                                <div class="task-name">${task.name}</div>
                                                <div class="task-project">${task.project.name}</div>
                                            </div>
                                            <div>
                                                <span class="badge ${task.status == 'EN_COURS' ? 'in-progress' : task.status == 'VALIDEE' ? 'completed' : 'todo'}">
                                                    ${task.status}
                                                </span>
                                            </div>
                                        </li>
                                    </c:if>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Overdue Tasks</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty overdueTasks}">
                            <div class="empty-state">
                                <p>No overdue tasks</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="task-list">
                                <c:forEach items="${overdueTasks}" var="task">
                                    <li class="task-item">
                                        <div>
                                            <div class="task-name">${task.name}</div>
                                            <div class="task-project">Due: <fmt:formatDate value="${task.dueDate}" pattern="MMM dd, yyyy"/></div>
                                        </div>
                                        <span class="badge danger">OVERDUE</span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Current Week Timesheet</div>
                <div class="card-body">
                    <c:if test="${not empty currentTimesheet}">
                        <div style="margin-bottom: 1rem;">
                            <strong>Week:</strong>
                            <fmt:formatDate value="${currentTimesheet.weekStartDate}" pattern="MMM dd"/> -
                            <fmt:formatDate value="${currentTimesheet.weekEndDate}" pattern="MMM dd, yyyy"/>
                        </div>
                        <div style="margin-bottom: 1rem;">
                            <strong>Total Hours:</strong> ${currentTimesheet.totalHours}
                        </div>
                        <div style="margin-bottom: 1rem;">
                            <div class="timesheet-status ${currentTimesheet.status.toString().toLowerCase()}">
                                ${currentTimesheet.status}
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/timesheets" class="btn">View Timesheet</a>
                    </c:if>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Upcoming Tasks (Next 7 Days)</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty upcomingTasks}">
                            <div class="empty-state">
                                <p>No upcoming tasks</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <ul class="task-list">
                                <c:forEach items="${upcomingTasks}" var="task">
                                    <li class="task-item">
                                        <div>
                                            <div class="task-name">${task.name}</div>
                                            <div class="task-project">Due: <fmt:formatDate value="${task.dueDate}" pattern="MMM dd, yyyy"/></div>
                                        </div>
                                        <span class="badge ${task.priority == 'HIGH' ? 'high' : task.priority == 'MEDIUM' ? 'medium' : 'low'}">
                                            ${task.priority}
                                        </span>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</body>
</html>