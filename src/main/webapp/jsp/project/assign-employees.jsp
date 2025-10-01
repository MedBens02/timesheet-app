<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.timesheetapp.entity.Project" %>
<%@ page import="com.timesheetapp.entity.User" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    Project project = (Project) request.getAttribute("project");
    List<User> allEmployees = (List<User>) request.getAttribute("allEmployees");
    List<User> assignedEmployees = (List<User>) request.getAttribute("assignedEmployees");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assign Employees - <%= project.getName() %></title>
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
            max-width: 900px;
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

        .header .project-name {
            font-size: 18px;
            opacity: 0.9;
        }

        .content {
            padding: 40px;
        }

        .info-box {
            background: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 30px;
        }

        .search-box {
            margin-bottom: 25px;
        }

        .search-box input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }

        .search-box input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .employees-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }

        .employee-card {
            border: 2px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: white;
        }

        .employee-card:hover {
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
        }

        .employee-card.selected {
            border-color: #667eea;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
        }

        .employee-card .checkbox-wrapper {
            display: flex;
            align-items: start;
            gap: 12px;
        }

        .employee-card input[type="checkbox"] {
            margin-top: 3px;
            width: 18px;
            height: 18px;
            cursor: pointer;
        }

        .employee-info {
            flex: 1;
        }

        .employee-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
        }

        .employee-email {
            font-size: 13px;
            color: #666;
        }

        .selection-summary {
            background: #f8f9fa;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .selection-summary strong {
            color: #667eea;
            font-size: 16px;
        }

        .quick-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
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

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
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

        .btn-outline {
            background: white;
            color: #667eea;
            border: 1px solid #667eea;
        }

        .btn-outline:hover {
            background: #667eea;
            color: white;
        }

        .actions {
            display: flex;
            gap: 15px;
            padding-top: 30px;
            border-top: 1px solid #e9ecef;
        }

        .no-employees {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Assign Employees to Project</h1>
            <div class="project-name"><%= project.getName() %></div>
        </div>

        <div class="content">
            <div class="info-box">
                <strong>How it works:</strong>
                Select employees from the list below to assign them to this project.
                Assigned employees will be able to view the project and its tasks on their dashboard.
            </div>

            <% if (allEmployees == null || allEmployees.isEmpty()) { %>
                <div class="no-employees">
                    <p>No employees available to assign.</p>
                </div>
            <% } else { %>
                <form action="<%= request.getContextPath() %>/project/save-assignments" method="post" id="assignmentForm">
                    <input type="hidden" name="projectId" value="<%= project.getId() %>">

                    <div class="search-box">
                        <input type="text" id="searchInput" placeholder="🔍 Search employees by name or email..." onkeyup="filterEmployees()">
                    </div>

                    <div class="quick-actions">
                        <button type="button" class="btn btn-outline btn-sm" onclick="selectAll()">Select All</button>
                        <button type="button" class="btn btn-outline btn-sm" onclick="deselectAll()">Deselect All</button>
                    </div>

                    <div class="selection-summary">
                        <div>
                            <strong id="selectedCount">0</strong> employee(s) selected
                        </div>
                    </div>

                    <div class="employees-grid" id="employeesGrid">
                        <% for (User employee : allEmployees) {
                            boolean isAssigned = assignedEmployees.stream()
                                .anyMatch(e -> e.getId().equals(employee.getId()));
                        %>
                            <div class="employee-card <%= isAssigned ? "selected" : "" %>" data-name="<%= employee.getFullName().toLowerCase() %>" data-email="<%= employee.getEmail().toLowerCase() %>">
                                <div class="checkbox-wrapper">
                                    <input
                                        type="checkbox"
                                        name="employeeIds"
                                        value="<%= employee.getId() %>"
                                        id="emp_<%= employee.getId() %>"
                                        <%= isAssigned ? "checked" : "" %>
                                        onchange="updateCard(this)">
                                    <label for="emp_<%= employee.getId() %>" class="employee-info">
                                        <div class="employee-name"><%= employee.getFullName() %></div>
                                        <div class="employee-email"><%= employee.getEmail() %></div>
                                    </label>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <div class="actions">
                        <button type="submit" class="btn btn-primary">
                            Save Assignments
                        </button>
                        <a href="<%= request.getContextPath() %>/project/list" class="btn btn-secondary">
                            Cancel
                        </a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <script>
        function updateCard(checkbox) {
            const card = checkbox.closest('.employee-card');
            if (checkbox.checked) {
                card.classList.add('selected');
            } else {
                card.classList.remove('selected');
            }
            updateSelectionCount();
        }

        function updateSelectionCount() {
            const count = document.querySelectorAll('input[name="employeeIds"]:checked').length;
            document.getElementById('selectedCount').textContent = count;
        }

        function selectAll() {
            const checkboxes = document.querySelectorAll('input[name="employeeIds"]');
            checkboxes.forEach(cb => {
                if (!cb.checked) {
                    cb.checked = true;
                    updateCard(cb);
                }
            });
        }

        function deselectAll() {
            const checkboxes = document.querySelectorAll('input[name="employeeIds"]:checked');
            checkboxes.forEach(cb => {
                cb.checked = false;
                updateCard(cb);
            });
        }

        function filterEmployees() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const cards = document.querySelectorAll('.employee-card');

            cards.forEach(card => {
                const name = card.getAttribute('data-name');
                const email = card.getAttribute('data-email');

                if (name.includes(searchTerm) || email.includes(searchTerm)) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Initialize selection count on page load
        updateSelectionCount();
    </script>
</body>
</html>
