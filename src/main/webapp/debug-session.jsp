<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.timesheetapp.entity.User" %>
<!DOCTYPE html>
<html>
<head>
    <title>Debug Session Info</title>
</head>
<body>
    <h1>Session Debug Info</h1>

    <h2>Session Scope Variables:</h2>
    <ul>
        <li>currentUser: <%= session.getAttribute("currentUser") %></li>
        <li>userId: <%= session.getAttribute("userId") %></li>
        <li>username: <%= session.getAttribute("username") %></li>
        <li>userRole: <%= session.getAttribute("userRole") %></li>
    </ul>

    <% User currentUser = (User) session.getAttribute("currentUser"); %>
    <% if (currentUser != null) { %>
        <h2>Current User Details:</h2>
        <ul>
            <li>ID: <%= currentUser.getId() %></li>
            <li>Username: <%= currentUser.getUsername() %></li>
            <li>Full Name: <%= currentUser.getFullName() %></li>
            <li>Email: <%= currentUser.getEmail() %></li>
            <li>Role: <%= currentUser.getRole() %></li>
            <li>Role toString(): <%= currentUser.getRole().toString() %></li>
        </ul>

        <h2>Role Checks:</h2>
        <ul>
            <li>Is ADMIN? <%= currentUser.getRole() == User.UserRole.ADMIN %></li>
            <li>Is PROJECT_MANAGER? <%= currentUser.getRole() == User.UserRole.PROJECT_MANAGER %></li>
            <li>Is EMPLOYEE? <%= currentUser.getRole() == User.UserRole.EMPLOYEE %></li>
        </ul>
    <% } else { %>
        <p>No user in session!</p>
    <% } %>

    <hr>
    <a href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
</body>
</html>
