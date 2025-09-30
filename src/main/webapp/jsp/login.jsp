<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Timesheet Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .login-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            max-width: 400px;
            width: 100%;
        }

        .login-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .login-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .login-header p {
            font-size: 14px;
            opacity: 0.9;
        }

        .login-body {
            padding: 40px 30px;
        }

        .alert {
            padding: 12px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-error {
            background-color: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }

        .alert-success {
            background-color: #efe;
            color: #3c3;
            border: 1px solid #cfc;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }

        .form-group input[type="text"],
        .form-group input[type="password"] {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group-checkbox {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .form-group-checkbox input[type="checkbox"] {
            margin-right: 8px;
            width: 16px;
            height: 16px;
        }

        .form-group-checkbox label {
            font-size: 14px;
            color: #666;
            cursor: pointer;
        }

        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn:active {
            transform: translateY(0);
        }

        .login-footer {
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            border-top: 1px solid #e9ecef;
        }

        .login-footer p {
            font-size: 13px;
            color: #666;
        }

        .demo-credentials {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            border-left: 4px solid #667eea;
        }

        .demo-credentials h4 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 14px;
        }

        .demo-credentials ul {
            list-style: none;
            font-size: 13px;
            color: #666;
        }

        .demo-credentials ul li {
            margin-bottom: 5px;
        }

        .demo-credentials ul li strong {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>Timesheet System</h1>
            <p>Project & Task Management</p>
        </div>

        <div class="login-body">
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <c:out value="${error}" />
                </div>
            </c:if>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    <c:out value="${successMessage}" />
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text"
                           id="username"
                           name="username"
                           placeholder="Enter your username"
                           value="${username}"
                           required
                           autofocus>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password"
                           id="password"
                           name="password"
                           placeholder="Enter your password"
                           required>
                </div>

                <div class="form-group-checkbox">
                    <input type="checkbox" id="rememberMe" name="rememberMe">
                    <label for="rememberMe">Remember me for 24 hours</label>
                </div>

                <button type="submit" class="btn">Sign In</button>
            </form>

            <div class="demo-credentials">
                <h4>Demo Credentials</h4>
                <ul>
                    <li><strong>Admin:</strong> admin / admin123</li>
                    <li><strong>Manager:</strong> jsmith / manager123</li>
                    <li><strong>Employee:</strong> mjohnson / employee123</li>
                </ul>
            </div>
        </div>

        <div class="login-footer">
            <p>&copy; 2024 Timesheet Management System. All rights reserved.</p>
        </div>
    </div>
</body>
</html>