package com.timesheetapp.controller;

import com.timesheetapp.entity.User;
import com.timesheetapp.service.UserService;
import com.timesheetapp.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            handleLogout(request, response);
        } else {
            // Check if user is already logged in
            if (SessionUtil.isUserLoggedIn(request)) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }

            // Show login page
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/login".equals(path)) {
            handleLogin(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        // Validate input
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            return;
        }

        try {
            // Authenticate user
            Optional<User> userOpt = userService.authenticate(username.trim(), password);

            if (userOpt.isEmpty()) {
                request.setAttribute("error", "Invalid username or password");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
                return;
            }

            User user = userOpt.get();

            // Check if user is active
            if (!user.getIsActive()) {
                request.setAttribute("error", "Your account has been deactivated. Please contact the administrator.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
                return;
            }

            // Create session
            SessionUtil.createUserSession(request, user);

            // Set session timeout based on "Remember Me"
            if ("on".equals(rememberMe) || "true".equals(rememberMe)) {
                SessionUtil.setSessionTimeout(request, 86400); // 24 hours
            }

            // Log successful login
            System.out.println("User logged in: " + user.getUsername() + " [" + user.getRole() + "]");

            // Get redirect URL or default to dashboard
            String redirectUrl = SessionUtil.getRedirectUrl(request);
            if (redirectUrl == null || redirectUrl.isEmpty()) {
                redirectUrl = getDashboardUrlForRole(request, user);
            }

            response.sendRedirect(redirectUrl);

        } catch (IllegalStateException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("username", username);
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Login error: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred during login. Please try again.");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = SessionUtil.getCurrentUser(request);
        if (user != null) {
            System.out.println("User logged out: " + user.getUsername());
        }

        // Invalidate session
        SessionUtil.invalidateSession(request);

        // Set logout message
        SessionUtil.setSuccessMessage(request, "You have been successfully logged out.");

        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private String getDashboardUrlForRole(HttpServletRequest request, User user) {
        String contextPath = request.getContextPath();

        switch (user.getRole()) {
            case ADMIN:
                return contextPath + "/admin/dashboard";
            case PROJECT_MANAGER:
                return contextPath + "/manager/dashboard";
            case EMPLOYEE:
                return contextPath + "/employee/dashboard";
            default:
                return contextPath + "/dashboard";
        }
    }
}