package com.timesheetapp.util;

import com.timesheetapp.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public class SessionUtil {

    private static final String USER_SESSION_KEY = "currentUser";
    private static final String USER_ID_SESSION_KEY = "userId";
    private static final String USERNAME_SESSION_KEY = "username";
    private static final String USER_ROLE_SESSION_KEY = "userRole";
    private static final String SESSION_TIMEOUT = "sessionTimeout";

    // Session timeout in seconds (30 minutes)
    private static final int DEFAULT_SESSION_TIMEOUT = 1800;

    public static void createUserSession(HttpServletRequest request, User user) {
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }

        HttpSession session = request.getSession(true);
        session.setAttribute(USER_SESSION_KEY, user);
        session.setAttribute(USER_ID_SESSION_KEY, user.getId());
        session.setAttribute(USERNAME_SESSION_KEY, user.getUsername());
        session.setAttribute(USER_ROLE_SESSION_KEY, user.getRole().toString());
        session.setMaxInactiveInterval(DEFAULT_SESSION_TIMEOUT);
    }

    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute(USER_SESSION_KEY);
    }

    public static Long getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (Long) session.getAttribute(USER_ID_SESSION_KEY);
    }

    public static String getCurrentUsername(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(USERNAME_SESSION_KEY);
    }

    public static String getCurrentUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (String) session.getAttribute(USER_ROLE_SESSION_KEY);
    }

    public static boolean isUserLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(USER_SESSION_KEY) != null;
    }

    public static boolean isAdmin(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

    public static boolean isProjectManager(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == User.UserRole.PROJECT_MANAGER;
    }

    public static boolean isEmployee(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == User.UserRole.EMPLOYEE;
    }

    public static boolean hasRole(HttpServletRequest request, User.UserRole role) {
        User user = getCurrentUser(request);
        return user != null && user.getRole() == role;
    }

    public static boolean canManageProjects(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && user.canManageProjects();
    }

    public static void invalidateSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }

    public static void updateSessionUser(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(false);
        if (session != null && user != null) {
            session.setAttribute(USER_SESSION_KEY, user);
            session.setAttribute(USER_ID_SESSION_KEY, user.getId());
            session.setAttribute(USERNAME_SESSION_KEY, user.getUsername());
            session.setAttribute(USER_ROLE_SESSION_KEY, user.getRole().toString());
        }
    }

    public static void setSessionTimeout(HttpServletRequest request, int seconds) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setMaxInactiveInterval(seconds);
        }
    }

    public static String getLoginUrl(HttpServletRequest request) {
        return request.getContextPath() + "/login";
    }

    public static String getDashboardUrl(HttpServletRequest request) {
        return request.getContextPath() + "/dashboard";
    }

    public static void setErrorMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute("errorMessage", message);
    }

    public static String getErrorMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        String message = (String) session.getAttribute("errorMessage");
        session.removeAttribute("errorMessage");
        return message;
    }

    public static void setSuccessMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute("successMessage", message);
    }

    public static String getSuccessMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        String message = (String) session.getAttribute("successMessage");
        session.removeAttribute("successMessage");
        return message;
    }

    public static void setRedirectUrl(HttpServletRequest request, String url) {
        HttpSession session = request.getSession(true);
        session.setAttribute("redirectUrl", url);
    }

    public static String getRedirectUrl(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        String url = (String) session.getAttribute("redirectUrl");
        session.removeAttribute("redirectUrl");
        return url;
    }

    public static boolean requireLogin(HttpServletRequest request) {
        return !isUserLoggedIn(request);
    }

    public static boolean requireRole(HttpServletRequest request, User.UserRole role) {
        return !hasRole(request, role);
    }
}