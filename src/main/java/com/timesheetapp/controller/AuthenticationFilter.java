package com.timesheetapp.controller;

import com.timesheetapp.entity.User;
import com.timesheetapp.util.SessionUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    // Public URLs that don't require authentication
    private static final List<String> PUBLIC_URLS = Arrays.asList(
        "/login",
        "/logout",
        "/",
        "/index.jsp"
    );

    // Static resources that don't require authentication
    private static final List<String> PUBLIC_RESOURCES = Arrays.asList(
        "/css/",
        "/js/",
        "/images/",
        "/fonts/"
    );

    // Admin-only URLs
    private static final List<String> ADMIN_URLS = Arrays.asList(
        "/admin/"
    );

    // Manager URLs (accessible by managers and admins)
    private static final List<String> MANAGER_URLS = Arrays.asList(
        "/manager/"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthenticationFilter initialized");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // Allow public URLs
        if (isPublicUrl(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Allow static resources
        if (isPublicResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        if (!SessionUtil.isUserLoggedIn(request)) {
            // Save the requested URL for redirect after login
            if (!"GET".equalsIgnoreCase(request.getMethod())) {
                SessionUtil.setRedirectUrl(request, request.getContextPath() + "/dashboard");
            } else {
                SessionUtil.setRedirectUrl(request, uri);
            }
            SessionUtil.setErrorMessage(request, "Please log in to access this page.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Check role-based access
        User user = SessionUtil.getCurrentUser(request);

        // Admin-only URLs
        if (isAdminUrl(path) && user.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Administrator privileges required.");
            return;
        }

        // Manager URLs (accessible by managers and admins)
        if (isManagerUrl(path) && !user.canManageProjects()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Manager privileges required.");
            return;
        }

        // User is authenticated and authorized
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        System.out.println("AuthenticationFilter destroyed");
    }

    private boolean isPublicUrl(String path) {
        for (String publicUrl : PUBLIC_URLS) {
            if (path.equals(publicUrl) || path.startsWith(publicUrl)) {
                return true;
            }
        }
        return false;
    }

    private boolean isPublicResource(String path) {
        for (String resource : PUBLIC_RESOURCES) {
            if (path.startsWith(resource)) {
                return true;
            }
        }
        return false;
    }

    private boolean isAdminUrl(String path) {
        for (String adminUrl : ADMIN_URLS) {
            if (path.startsWith(adminUrl)) {
                return true;
            }
        }
        return false;
    }

    private boolean isManagerUrl(String path) {
        for (String managerUrl : MANAGER_URLS) {
            if (path.startsWith(managerUrl)) {
                return true;
            }
        }
        return false;
    }
}