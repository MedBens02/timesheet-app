<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Timesheet Management System</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Timesheet Management System</h1>
            <p>Professional Time Tracking for Projects and Teams</p>
        </header>
        
        <main>
            <div class="login-section">
                <h2>Welcome</h2>
                <p>Please log in to access your timesheet dashboard.</p>
                
                <div class="action-buttons">
                    <a href="login" class="btn btn-primary">Login</a>
                    <a href="about.jsp" class="btn btn-secondary">About</a>
                </div>
            </div>
            
            <div class="features">
                <h3>Key Features</h3>
                <ul>
                    <li>Project and Task Management</li>
                    <li>Weekly Timesheet Entry</li>
                    <li>Overtime Calculation (1.25x)</li>
                    <li>Progress Tracking & Reporting</li>
                    <li>Role-based Access Control</li>
                </ul>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2024 Timesheet Management System. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>