<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Employee Dashboard - Timesheet System</title>
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
                    <h1 class="h3 mb-2 text-gray-800">Welcome back, ${sessionScope.currentUser.firstName}!</h1>
                    <p class="mb-4">Here's your activity summary and pending tasks</p>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- Total Tasks Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-primary shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                Total Tasks</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${totalTasks}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-tasks fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Completed Tasks Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-success shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                Completed</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${completedTasks}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-check-circle fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- In Progress Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-info shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">In Progress
                                            </div>
                                            <div class="row no-gutters align-items-center">
                                                <div class="col-auto">
                                                    <div class="h5 mb-0 mr-3 font-weight-bold text-gray-800">${inProgressTasks}</div>
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

                        <!-- Overdue Card -->
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-warning shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                Overdue</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">${overdueCount}</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-exclamation-triangle fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Content Row -->
                    <div class="row">

                        <!-- My Active Tasks Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">My Active Tasks</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty myTasks}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-inbox fa-3x mb-3"></i>
                                                <p>No active tasks assigned</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${myTasks}" var="task" varStatus="status">
                                                <c:if test="${status.index < 5}">
                                                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                        <div>
                                                            <div class="font-weight-bold text-gray-800">${task.name}</div>
                                                            <small class="text-gray-600">${task.project.name}</small>
                                                        </div>
                                                        <span class="badge badge-${task.status == 'EN_COURS' ? 'info' : task.status == 'VALIDEE' ? 'success' : 'secondary'} badge-pill">
                                                            ${task.status}
                                                        </span>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Current Week Timesheet Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">Current Week Timesheet</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${not empty currentTimesheet}">
                                            <div class="mb-3">
                                                <strong>Week:</strong>
                                                ${currentTimesheet.weekStartDate} - ${currentTimesheet.weekEndDate}
                                            </div>
                                            <div class="mb-3">
                                                <div class="d-flex justify-content-between mb-2">
                                                    <span class="text-gray-700"><strong>Total Hours:</strong></span>
                                                    <span class="font-weight-bold text-gray-800">${currentTimesheet.totalHours}h</span>
                                                </div>
                                                <div class="progress" style="height: 20px;">
                                                    <div class="progress-bar ${currentTimesheet.totalHours > 40 ? 'bg-warning' : 'bg-success'}"
                                                         role="progressbar"
                                                         style="width: ${currentTimesheet.totalHours * 100 / 40}%"
                                                         aria-valuenow="${currentTimesheet.totalHours}"
                                                         aria-valuemin="0"
                                                         aria-valuemax="40">
                                                        ${currentTimesheet.totalHours}h / 40h
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="mb-3">
                                                <span class="badge badge-${currentTimesheet.status == 'DRAFT' ? 'secondary' : currentTimesheet.status == 'SUBMITTED' ? 'warning' : currentTimesheet.status == 'VALIDATED' ? 'success' : 'danger'} badge-pill">
                                                    ${currentTimesheet.status}
                                                </span>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/timesheets" class="btn btn-primary btn-sm">View Timesheet</a>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-calendar-plus fa-3x mb-3"></i>
                                                <p>No timesheet for current week</p>
                                                <a href="${pageContext.request.contextPath}/timesheets" class="btn btn-primary btn-sm">Create Timesheet</a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Content Row -->
                    <div class="row">

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
                                                <i class="fas fa-thumbs-up fa-3x mb-3 text-success"></i>
                                                <p>No overdue tasks</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${overdueTasks}" var="task" varStatus="status">
                                                <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                    <div>
                                                        <div class="font-weight-bold text-gray-800">${task.name}</div>
                                                        <small class="text-gray-600">Due: ${task.dueDate}</small>
                                                    </div>
                                                    <span class="badge badge-danger badge-pill">OVERDUE</span>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Upcoming Tasks Card -->
                        <div class="col-lg-6 mb-4">
                            <div class="card shadow mb-4">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">Upcoming Tasks (Next 7 Days)</h6>
                                </div>
                                <div class="card-body">
                                    <c:choose>
                                        <c:when test="${empty upcomingTasks}">
                                            <div class="text-center text-gray-500 py-4">
                                                <i class="fas fa-calendar-check fa-3x mb-3 text-info"></i>
                                                <p>No upcoming tasks</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach items="${upcomingTasks}" var="task" varStatus="status">
                                                <div class="d-flex justify-content-between align-items-center mb-3 pb-3 ${status.last ? '' : 'border-bottom'}">
                                                    <div>
                                                        <div class="font-weight-bold text-gray-800">${task.name}</div>
                                                        <small class="text-gray-600">Due: ${task.dueDate}</small>
                                                    </div>
                                                    <span class="badge badge-${task.priority == 'HIGH' || task.priority == 'URGENT' ? 'danger' : task.priority == 'MEDIUM' ? 'warning' : 'secondary'} badge-pill">
                                                        ${task.priority}
                                                    </span>
                                                </div>
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
