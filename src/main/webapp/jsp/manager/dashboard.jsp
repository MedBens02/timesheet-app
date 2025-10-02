<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Manager Dashboard - Timesheet System</title>
    <jsp:include page="../includes/head.jsp" />
</head>

<body id="page-top">

    <!-- Page Wrapper -->
    <div id="wrapper">

        <jsp:include page="../includes/sidebar.jsp" />

        <!-- Content Wrapper -->
        <div id="content-wrapper" class="d-flex flex-column">

            <!-- Main Content -->
            <div id="content">

                <jsp:include page="../includes/topbar.jsp" />

                <!-- Begin Page Content -->
                <div class="container-fluid">

                    <!-- Page Heading -->
                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">Manager Dashboard</h1>
                        <a href="${pageContext.request.contextPath}/project/create" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm">
                            <i class="fas fa-plus fa-sm text-white-50"></i> Create Project
                        </a>
                    </div>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- Total Projects Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-primary shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                Total Projects</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${totalProjects}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-folder fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Active Projects Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-success shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                Active Projects</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${activeProjectCount}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-tasks fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Total Tasks Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-info shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Total Tasks
                                            </div>
                                            <div class="row no-gutters align-items-center">
                                                <div class="col-auto">
                                                    <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800">${totalTasks}</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-clipboard-list fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Overdue Tasks Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-warning shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                Overdue Tasks</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${overdueTaskCount}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-exclamation-triangle fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Second Row -->
                    <div class="row">
                        <!-- Pending Validations Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-danger shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">
                                                Pending Validations</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${pendingValidations}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-hourglass-half fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- My Projects Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                    <h6 class="m-0 font-weight-bold text-primary">My Projects</h6>
                                    <a href="${pageContext.request.contextPath}/project/list" class="btn btn-sm btn-primary">View All</a>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty myProjects}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-folder-open fa-3x mb-3"></i>
                                                <p>No projects assigned</p>
                                                <a href="${pageContext.request.contextPath}/project/create" class="btn btn-sm btn-primary">Create Your First Project</a>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${myProjects}" var="project" varStatus="status">
                                                <c:if test="${status.index < 5}">
                                                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                        <div>
                                                            <div class="font-weight-bold text-gray-800">${project.name}</div>
                                                            <small class="text-gray-600">${project.estimatedHours} estimated hours</small>
                                                        </div>
                                                        <span class="badge badge-${project.status == 'ACTIF' ? 'success' : project.status == 'TERMINE' ? 'primary' : 'warning'} badge-pill">
                                                            ${project.status}
                                                        </span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Overdue Tasks Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">Overdue Tasks</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty overdueTasks}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-check-circle fa-3x mb-3 text-success"></i>
                                                <p>No overdue tasks</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${overdueTasks}" var="task" varStatus="status">
                                                <c:if test="${status.index < 5}">
                                                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                        <div>
                                                            <div class="font-weight-bold text-gray-800">${task.name}</div>
                                                            <small class="text-gray-600">${task.project.name} - ${task.assignedTo.fullName}</small>
                                                        </div>
                                                        <span class="badge badge-danger badge-pill">OVERDUE</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                    </div>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- High Priority Tasks Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">High Priority Tasks</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty highPriorityTasks}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-thumbs-up fa-3x mb-3 text-info"></i>
                                                <p>No high priority tasks</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${highPriorityTasks}" var="task" varStatus="status">
                                                <c:if test="${status.index < 5}">
                                                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                        <div>
                                                            <div class="font-weight-bold text-gray-800">${task.name}</div>
                                                            <small class="text-gray-600">${task.project.name}</small>
                                                        </div>
                                                        <span class="badge badge-danger badge-pill">${task.priority}</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Timesheets Awaiting Validation Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">Timesheets Awaiting Validation</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty timesheetsForValidation}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-clipboard-check fa-3x mb-3 text-success"></i>
                                                <p>No pending timesheets</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${timesheetsForValidation}" var="timesheet" varStatus="status">
                                                <c:if test="${status.index < 5}">
                                                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                        <div>
                                                            <div class="font-weight-bold text-gray-800">${timesheet.user.fullName}</div>
                                                            <small class="text-gray-600">
                                                                ${timesheet.weekStartDate} - ${timesheet.weekEndDate}
                                                                (${timesheet.totalHours}h)
                                                            </small>
                                                        </div>
                                                        <span class="badge badge-warning badge-pill">PENDING</span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                    </div>

                </div>
                <!-- /.container-fluid -->

            </div>
            <!-- End of Main Content -->

            <jsp:include page="../includes/footer.jsp" />

        </div>
        <!-- End of Content Wrapper -->

    </div>
    <!-- End of Page Wrapper -->

    <!-- Scroll to Top Button-->
    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <jsp:include page="../includes/logout-modal.jsp" />

    <jsp:include page="../includes/scripts.jsp" />

</body>

</html>
