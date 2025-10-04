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

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile/view", "/profile/edit"})
public class ProfileServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get fresh user data from database
            User user = userService.getUserById(currentUser.getId());

            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }

            request.setAttribute("user", user);
            request.getRequestDispatcher("/jsp/profile/profile.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get form parameters
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            // Update profile information
            if (firstName != null && !firstName.trim().isEmpty() &&
                lastName != null && !lastName.trim().isEmpty() &&
                email != null && !email.trim().isEmpty()) {

                userService.updateUserProfile(currentUser.getId(), firstName.trim(), lastName.trim(), email.trim());
            }

            // Change password if provided
            if (currentPassword != null && !currentPassword.isEmpty() &&
                newPassword != null && !newPassword.isEmpty()) {

                // Validate that new password and confirm password match
                if (!newPassword.equals(confirmPassword)) {
                    SessionUtil.setErrorMessage(request, "New password and confirm password do not match");
                    response.sendRedirect(request.getContextPath() + "/profile/view");
                    return;
                }

                // Change password
                userService.changePassword(currentUser.getId(), currentPassword, newPassword);
            }

            // Update session with fresh user data
            User updatedUser = userService.getUserById(currentUser.getId());
            SessionUtil.updateSessionUser(request, updatedUser);

            SessionUtil.setSuccessMessage(request, "Profile updated successfully!");
            response.sendRedirect(request.getContextPath() + "/profile/view");

        } catch (IllegalArgumentException e) {
            SessionUtil.setErrorMessage(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/profile/view");
        } catch (IllegalStateException e) {
            SessionUtil.setErrorMessage(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/profile/view");
        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/profile/view");
        }
    }
}
