<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.timesheetapp.entity.Project" %>
<%@ page import="com.timesheetapp.entity.User" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    Project project = (Project) request.getAttribute("project");
    String action = (String) request.getAttribute("action");
    List<User> managers = (List<User>) request.getAttribute("managers");
    String errorMsg = (String) request.getAttribute("error");
    boolean isEdit = "edit".equals(action);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit Project" : "Create Project" %> - Timesheet Management</title>
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
            max-width: 800px;
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
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .content {
            padding: 40px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }

        .form-group label .required {
            color: #dc3545;
            margin-left: 3px;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-group .help-text {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 25px;
            border: 1px solid #f5c6cb;
        }

        .actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid #e9ecef;
        }

        .btn {
            padding: 12px 24px;
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

        .btn-secondary:hover {
            background: #5a6268;
        }

        .info-box {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 25px;
        }

        .info-box strong {
            display: block;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><%= isEdit ? "Edit Project" : "Create New Project" %></h1>
            <p><%= isEdit ? "Update project information" : "Fill in the details to create a new project" %></p>
        </div>

        <div class="content">
            <% if (errorMsg != null) { %>
                <div class="error-message">
                    ✗ <%= errorMsg %>
                </div>
            <% } %>

            <% if (!isEdit) { %>
                <div class="info-box">
                    <strong>Project Workflow:</strong>
                    New projects start with status "En attente" (Awaiting Validation).
                    After creation, you can request validation from an administrator.
                    Once validated, you can create tasks and assign employees.
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/project/save" method="post" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="<%= action %>">
                <% if (isEdit && project != null) { %>
                    <input type="hidden" name="projectId" value="<%= project.getId() %>">
                <% } %>

                <div class="form-group">
                    <label for="name">
                        Project Name
                        <span class="required">*</span>
                    </label>
                    <input
                        type="text"
                        id="name"
                        name="name"
                        value="<%= isEdit && project != null ? project.getName() : "" %>"
                        required
                        maxlength="100"
                        placeholder="e.g., E-commerce Platform Development">
                    <div class="help-text">Maximum 100 characters</div>
                </div>

                <div class="form-group">
                    <label for="clientName">Client Name</label>
                    <input
                        type="text"
                        id="clientName"
                        name="clientName"
                        value="<%= isEdit && project != null && project.getClientName() != null ? project.getClientName() : "" %>"
                        maxlength="200"
                        placeholder="e.g., ABC Corporation">
                    <div class="help-text">Optional - Name of the client for this project</div>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea
                        id="description"
                        name="description"
                        placeholder="Describe the project objectives, scope, and deliverables..."><%= isEdit && project != null && project.getDescription() != null ? project.getDescription() : "" %></textarea>
                </div>

                <% if (currentUser.getRole() == User.UserRole.ADMIN && managers != null) { %>
                    <div class="form-group">
                        <label for="managerId">
                            Project Manager
                            <span class="required">*</span>
                        </label>
                        <select id="managerId" name="managerId" required>
                            <option value="">-- Select Manager --</option>
                            <% for (User manager : managers) { %>
                                <option value="<%= manager.getId() %>"
                                    <%= isEdit && project != null && project.getManager().getId().equals(manager.getId()) ? "selected" : "" %>>
                                    <%= manager.getFullName() %> (<%= manager.getEmail() %>)
                                </option>
                            <% } %>
                        </select>
                        <div class="help-text">Assign a project manager to oversee this project</div>
                    </div>
                <% } else { %>
                    <div class="info-box">
                        <strong>Project Manager:</strong>
                        <%= currentUser.getFullName() %> (You)
                    </div>
                <% } %>

                <div class="form-row">
                    <div class="form-group">
                        <label for="startDate">Start Date</label>
                        <input
                            type="date"
                            id="startDate"
                            name="startDate"
                            value="<%= isEdit && project != null && project.getStartDate() != null ? project.getStartDate().toString() : "" %>">
                    </div>

                    <div class="form-group">
                        <label for="endDate">End Date</label>
                        <input
                            type="date"
                            id="endDate"
                            name="endDate"
                            value="<%= isEdit && project != null && project.getEndDate() != null ? project.getEndDate().toString() : "" %>">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="estimatedHours">Estimated Hours</label>
                        <input
                            type="number"
                            id="estimatedHours"
                            name="estimatedHours"
                            value="<%= isEdit && project != null ? project.getEstimatedHours() : "" %>"
                            min="0"
                            step="1"
                            placeholder="0">
                        <div class="help-text">Total estimated project hours</div>
                    </div>

                    <div class="form-group">
                        <label for="estimatedCost">Estimated Cost ($)</label>
                        <input
                            type="number"
                            id="estimatedCost"
                            name="estimatedCost"
                            value="<%= isEdit && project != null ? project.getEstimatedCost() : "" %>"
                            min="0"
                            step="0.01"
                            placeholder="0.00">
                        <div class="help-text">Budget allocation for this project</div>
                    </div>
                </div>

                <div class="actions">
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "Update Project" : "Create Project" %>
                    </button>
                    <a href="<%= request.getContextPath() %>/project/list" class="btn btn-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function validateForm() {
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;

            if (startDate && endDate && new Date(endDate) < new Date(startDate)) {
                alert('End date must be after start date');
                return false;
            }

            return true;
        }

        // Set minimum end date based on start date
        document.getElementById('startDate').addEventListener('change', function() {
            const endDateInput = document.getElementById('endDate');
            endDateInput.min = this.value;
        });
    </script>
</body>
</html>