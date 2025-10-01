<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.timesheetapp.entity.Project" %>
<%@ page import="com.timesheetapp.entity.User" %>
<%@ page import="com.timesheetapp.entity.Project.ProjectStatus" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    List<Project> projects = (List<Project>) request.getAttribute("projects");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String successMessage = (String) session.getAttribute("successMessage");
    String errorMessage = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projects - Timesheet Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .header .user-info {
            text-align: right;
        }

        .header .role-badge {
            display: inline-block;
            padding: 4px 12px;
            background: rgba(255,255,255,0.2);
            border-radius: 20px;
            font-size: 12px;
            margin-top: 5px;
        }

        .content {
            padding: 40px;
        }

        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .filters {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .filters select {
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background: white;
            cursor: pointer;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-success {
            background: #28a745;
            color: white;
        }

        .btn-warning {
            background: #ffc107;
            color: #333;
        }

        .btn-danger {
            background: #dc3545;
            color: white;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
        }

        .message {
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .message.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .projects-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .projects-table thead {
            background: #f8f9fa;
        }

        .projects-table th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #dee2e6;
        }

        .projects-table td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
            vertical-align: top;
        }

        .projects-table tbody tr:hover {
            background: #f8f9fa;
        }

        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-en-attente {
            background: #fff3cd;
            color: #856404;
        }

        .status-valide {
            background: #d4edda;
            color: #155724;
        }

        .status-actif {
            background: #d1ecf1;
            color: #0c5460;
        }

        .status-termine {
            background: #e2e3e5;
            color: #383d41;
        }

        .status-abandonne {
            background: #f8d7da;
            color: #721c24;
        }

        .project-info {
            margin-bottom: 5px;
        }

        .project-name {
            font-weight: 600;
            color: #333;
            font-size: 16px;
        }

        .project-client {
            color: #666;
            font-size: 13px;
            margin-top: 3px;
        }

        .project-manager {
            color: #666;
            font-size: 13px;
        }

        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            margin: 5px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s ease;
        }

        .progress-text {
            font-size: 12px;
            color: #666;
            margin-top: 3px;
        }

        .actions {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }

        .no-projects {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }

        .no-projects-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.3;
        }

        .nav-links {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
            display: flex;
            gap: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>Project Management</h1>
                <p>Manage and track all projects</p>
            </div>
            <div class="user-info">
                <div><%= currentUser.getFullName() %></div>
                <div class="role-badge"><%= currentUser.getRole() %></div>
            </div>
        </div>

        <div class="content">
            <% if (successMessage != null) { %>
                <div class="message success">
                    ✓ <%= successMessage %>
                </div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="message error">
                    ✗ <%= errorMessage %>
                </div>
            <% } %>

            <div class="action-bar">
                <div class="filters">
                    <label for="statusFilter">Filter by status:</label>
                    <select id="statusFilter" onchange="filterProjects()">
                        <option value="">All Statuses</option>
                        <option value="EN_ATTENTE" <%= "EN_ATTENTE".equals(statusFilter) ? "selected" : "" %>>En attente</option>
                        <option value="VALIDE" <%= "VALIDE".equals(statusFilter) ? "selected" : "" %>>Validé</option>
                        <option value="ACTIF" <%= "ACTIF".equals(statusFilter) ? "selected" : "" %>>Actif</option>
                        <option value="TERMINE" <%= "TERMINE".equals(statusFilter) ? "selected" : "" %>>Terminé</option>
                        <option value="ABANDONNE" <%= "ABANDONNE".equals(statusFilter) ? "selected" : "" %>>Abandonné</option>
                    </select>
                </div>

                <% if (currentUser.getRole() == User.UserRole.ADMIN || currentUser.getRole() == User.UserRole.PROJECT_MANAGER) { %>
                    <a href="<%= request.getContextPath() %>/project/create" class="btn btn-primary">
                        + Create New Project
                    </a>
                <% } %>
            </div>

            <% if (projects == null || projects.isEmpty()) { %>
                <div class="no-projects">
                    <div class="no-projects-icon">📁</div>
                    <h3>No Projects Found</h3>
                    <p>
                        <% if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER) { %>
                            Start by creating your first project!
                        <% } else if (currentUser.getRole() == User.UserRole.ADMIN) { %>
                            No projects have been created yet.
                        <% } else { %>
                            You haven't been assigned to any projects yet.
                        <% } %>
                    </p>
                </div>
            <% } else { %>
                <table class="projects-table">
                    <thead>
                        <tr>
                            <th>Project</th>
                            <th>Manager</th>
                            <th>Status</th>
                            <th>Progress</th>
                            <th>Estimated Hours</th>
                            <th>Dates</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Project project : projects) { %>
                            <tr>
                                <td>
                                    <div class="project-info">
                                        <div class="project-name"><%= project.getName() %></div>
                                        <% if (project.getClientName() != null && !project.getClientName().isEmpty()) { %>
                                            <div class="project-client">Client: <%= project.getClientName() %></div>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <div class="project-manager"><%= project.getManager().getFullName() %></div>
                                </td>
                                <td>
                                    <span class="status-badge status-<%= project.getStatus().toString().toLowerCase().replace("_", "-") %>">
                                        <%= project.getStatus().toString().replace("_", " ") %>
                                    </span>
                                </td>
                                <td>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: <%= project.getProgressPercentage() %>%"></div>
                                    </div>
                                    <div class="progress-text">
                                        <%= String.format("%.1f", project.getProgressPercentage()) %>%
                                        (<%= project.getActualHours() %>h / <%= project.getEstimatedHours() %>h)
                                    </div>
                                </td>
                                <td><%= project.getEstimatedHours() %> hours</td>
                                <td>
                                    <% if (project.getStartDate() != null) { %>
                                        <%= project.getStartDate() %><br>
                                    <% } %>
                                    <% if (project.getEndDate() != null) { %>
                                        to <%= project.getEndDate() %>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="actions">
                                        <% if (currentUser.getRole() == User.UserRole.ADMIN ||
                                               (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
                                                project.getManager().getId().equals(currentUser.getId()))) { %>

                                            <a href="<%= request.getContextPath() %>/project/edit?id=<%= project.getId() %>"
                                               class="btn btn-secondary btn-sm">Edit</a>

                                            <% if (project.getStatus() == ProjectStatus.EN_ATTENTE &&
                                                   currentUser.getRole() == User.UserRole.PROJECT_MANAGER) { %>
                                                <a href="<%= request.getContextPath() %>/project/request-validation?id=<%= project.getId() %>"
                                                   class="btn btn-warning btn-sm">Request Validation</a>
                                            <% } %>

                                            <% if (project.getStatus() == ProjectStatus.VALIDE ||
                                                   project.getStatus() == ProjectStatus.ACTIF) { %>
                                                <a href="<%= request.getContextPath() %>/project/assign-employees?id=<%= project.getId() %>"
                                                   class="btn btn-success btn-sm">Assign Employees</a>
                                            <% } %>

                                            <a href="<%= request.getContextPath() %>/project/delete?id=<%= project.getId() %>"
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Are you sure you want to delete this project?')">Delete</a>
                                        <% } %>

                                        <% if (currentUser.getRole() == User.UserRole.ADMIN &&
                                               project.getStatus() == ProjectStatus.EN_ATTENTE) { %>
                                            <a href="<%= request.getContextPath() %>/project/validate?id=<%= project.getId() %>"
                                               class="btn btn-success btn-sm">Validate</a>
                                            <a href="<%= request.getContextPath() %>/project/reject?id=<%= project.getId() %>"
                                               class="btn btn-danger btn-sm"
                                               onclick="return confirm('Are you sure you want to reject this project?')">Reject</a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>

            <div class="nav-links">
                <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-secondary">← Back to Dashboard</a>
            </div>
        </div>
    </div>

    <script>
        function filterProjects() {
            const status = document.getElementById('statusFilter').value;
            const url = new URL(window.location.href);
            if (status) {
                url.searchParams.set('status', status);
            } else {
                url.searchParams.delete('status');
            }
            window.location.href = url.toString();
        }
    </script>
</body>
</html>
