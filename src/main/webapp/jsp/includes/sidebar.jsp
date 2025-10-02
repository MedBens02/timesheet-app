<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Sidebar -->
<ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">

    <!-- Sidebar - Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="${pageContext.request.contextPath}/dashboard">
        <div class="sidebar-brand-icon rotate-n-15">
            <i class="fas fa-clock"></i>
        </div>
        <div class="sidebar-brand-text mx-3">Timesheet <sup>App</sup></div>
    </a>

    <!-- Divider -->
    <hr class="sidebar-divider my-0">

    <!-- Nav Item - Dashboard -->
    <li class="nav-item active">
        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
            <i class="fas fa-fw fa-tachometer-alt"></i>
            <span>Dashboard</span></a>
    </li>

    <!-- Divider -->
    <hr class="sidebar-divider">

    <!-- Heading -->
    <div class="sidebar-heading">
        Management
    </div>

    <!-- Admin Menu Items -->
    <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN'}">
        <!-- Nav Item - Projects -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/project/list">
                <i class="fas fa-fw fa-folder"></i>
                <span>All Projects</span></a>
        </li>

        <!-- Nav Item - Users -->
        <li class="nav-item">
            <a class="nav-link" href="#">
                <i class="fas fa-fw fa-users"></i>
                <span>Manage Users</span></a>
        </li>

        <!-- Nav Item - Validations -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/project/list?status=EN_ATTENTE">
                <i class="fas fa-fw fa-check-circle"></i>
                <span>Validate Projects</span></a>
        </li>

        <!-- Nav Item - Reports -->
        <li class="nav-item">
            <a class="nav-link" href="#">
                <i class="fas fa-fw fa-chart-area"></i>
                <span>Reports</span></a>
        </li>
    </c:if>

    <!-- Project Manager Menu Items -->
    <c:if test="${sessionScope.currentUser.role.toString() == 'PROJECT_MANAGER'}">
        <!-- Nav Item - My Projects -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/project/list">
                <i class="fas fa-fw fa-folder-open"></i>
                <span>My Projects</span></a>
        </li>

        <!-- Nav Item - Create Project -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/project/create">
                <i class="fas fa-fw fa-plus-circle"></i>
                <span>Create Project</span></a>
        </li>

        <!-- Nav Item - Tasks -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/task/list">
                <i class="fas fa-fw fa-tasks"></i>
                <span>Manage Tasks</span></a>
        </li>

        <!-- Nav Item - Timesheets -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/timesheet/validate">
                <i class="fas fa-fw fa-clipboard-check"></i>
                <span>Validate Timesheets</span></a>
        </li>
    </c:if>

    <!-- Employee Menu Items -->
    <c:if test="${sessionScope.currentUser.role.toString() == 'EMPLOYEE'}">
        <!-- Nav Item - My Tasks -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/task/list">
                <i class="fas fa-fw fa-list-check"></i>
                <span>My Tasks</span></a>
        </li>

        <!-- Nav Item - My Projects -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/project/list">
                <i class="fas fa-fw fa-folder"></i>
                <span>My Projects</span></a>
        </li>

        <!-- Nav Item - Timesheet Entry -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/timesheet/create">
                <i class="fas fa-fw fa-calendar-plus"></i>
                <span>Register Hours</span></a>
        </li>

        <!-- Nav Item - Timesheet History -->
        <li class="nav-item">
            <a class="nav-link" href="${pageContext.request.contextPath}/timesheet/list">
                <i class="fas fa-fw fa-history"></i>
                <span>Timesheet History</span></a>
        </li>
    </c:if>

    <!-- Divider -->
    <hr class="sidebar-divider d-none d-md-block">

    <!-- Sidebar Toggler (Sidebar) -->
    <div class="text-center d-none d-md-inline">
        <button class="rounded-circle border-0" id="sidebarToggle"></button>
    </div>

</ul>
<!-- End of Sidebar -->
