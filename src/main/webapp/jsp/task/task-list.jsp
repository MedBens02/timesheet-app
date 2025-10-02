<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Tasks - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
    <link href="${pageContext.request.contextPath}/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
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
                        <h1 class="h3 mb-0 text-gray-800">Task Management</h1>
                        <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN' || sessionScope.currentUser.role.toString() == 'PROJECT_MANAGER'}">
                            <a href="${pageContext.request.contextPath}/task/create" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm">
                                <i class="fas fa-plus fa-sm text-white-50"></i> Create New Task
                            </a>
                        </c:if>
                    </div>

                    <!-- Success/Error Messages -->
                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <c:remove var="successMessage" scope="session"/>
                    </c:if>

                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle"></i> ${sessionScope.errorMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <c:remove var="errorMessage" scope="session"/>
                    </c:if>

                    <!-- Filter Section -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Filter Tasks</h6>
                        </div>
                        <div class="card-body">
                            <form method="get" action="${pageContext.request.contextPath}/task/list" class="form-inline">
                                <label class="mr-2">Status:</label>
                                <select name="status" class="form-control form-control-sm mr-3" onchange="this.form.submit()">
                                    <option value="">All Statuses</option>
                                    <option value="A_FAIRE" ${param.status == 'A_FAIRE' ? 'selected' : ''}>À faire</option>
                                    <option value="EN_COURS" ${param.status == 'EN_COURS' ? 'selected' : ''}>En cours</option>
                                    <option value="VALIDEE" ${param.status == 'VALIDEE' ? 'selected' : ''}>Validée</option>
                                </select>

                                <label class="mr-2">Priority:</label>
                                <select name="priority" class="form-control form-control-sm mr-3" onchange="this.form.submit()">
                                    <option value="">All Priorities</option>
                                    <option value="LOW" ${param.priority == 'LOW' ? 'selected' : ''}>Low</option>
                                    <option value="MEDIUM" ${param.priority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                                    <option value="HIGH" ${param.priority == 'HIGH' ? 'selected' : ''}>High</option>
                                    <option value="URGENT" ${param.priority == 'URGENT' ? 'selected' : ''}>Urgent</option>
                                </select>
                            </form>
                        </div>
                    </div>

                    <!-- Tasks Table -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">All Tasks</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty tasks}">
                                    <div class="text-center text-gray-500 py-5">
                                        <i class="fas fa-tasks fa-4x mb-3"></i>
                                        <p class="h5">No Tasks Found</p>
                                        <c:if test="${sessionScope.currentUser.role.toString() == 'PROJECT_MANAGER'}">
                                            <a href="${pageContext.request.contextPath}/task/create" class="btn btn-primary mt-3">
                                                <i class="fas fa-plus"></i> Create Task
                                            </a>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                            <thead>
                                                <tr>
                                                    <th>Task</th>
                                                    <th>Project</th>
                                                    <th>Assigned To</th>
                                                    <th>Priority</th>
                                                    <th>Status</th>
                                                    <th>Due Date</th>
                                                    <th>Progress</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${tasks}" var="task">
                                                    <tr>
                                                        <td>
                                                            <div class="font-weight-bold">${task.name}</div>
                                                            <c:if test="${not empty task.description}">
                                                                <small class="text-gray-600">${task.description}</small>
                                                            </c:if>
                                                        </td>
                                                        <td>${task.project.name}</td>
                                                        <td>${task.assignedTo.fullName}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${task.priority == 'URGENT'}">
                                                                    <span class="badge badge-danger">Urgent</span>
                                                                </c:when>
                                                                <c:when test="${task.priority == 'HIGH'}">
                                                                    <span class="badge badge-warning">High</span>
                                                                </c:when>
                                                                <c:when test="${task.priority == 'MEDIUM'}">
                                                                    <span class="badge badge-info">Medium</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-secondary">Low</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${task.status == 'A_FAIRE'}">
                                                                    <span class="badge badge-secondary">À faire</span>
                                                                </c:when>
                                                                <c:when test="${task.status == 'EN_COURS'}">
                                                                    <span class="badge badge-info">En cours</span>
                                                                </c:when>
                                                                <c:when test="${task.status == 'VALIDEE'}">
                                                                    <span class="badge badge-success">Validée</span>
                                                                </c:when>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:if test="${not empty task.dueDate}">
                                                                ${task.dueDate}
                                                                <c:if test="${task.overdue}">
                                                                    <br><span class="badge badge-danger badge-sm">Overdue</span>
                                                                </c:if>
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <div class="progress" style="height: 20px;">
                                                                <div class="progress-bar ${task.progressPercentage >= 100 ? 'bg-success' : task.progressPercentage >= 50 ? 'bg-info' : 'bg-warning'}"
                                                                     role="progressbar"
                                                                     style="width: ${task.progressPercentage}%">
                                                                    ${task.progressPercentage}%
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="btn-group-vertical btn-group-sm" role="group">
                                                                <a href="${pageContext.request.contextPath}/task/view?id=${task.id}" class="btn btn-info btn-sm mb-1">
                                                                    <i class="fas fa-eye"></i> View
                                                                </a>
                                                                <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN' || (sessionScope.currentUser.role.toString() == 'PROJECT_MANAGER' && task.project.manager.id == sessionScope.currentUser.id)}">
                                                                    <a href="${pageContext.request.contextPath}/task/edit?id=${task.id}" class="btn btn-secondary btn-sm mb-1">
                                                                        <i class="fas fa-edit"></i> Edit
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/task/delete?id=${task.id}"
                                                                       class="btn btn-danger btn-sm mb-1"
                                                                       onclick="return confirm('Are you sure you want to delete this task?')">
                                                                        <i class="fas fa-trash"></i> Delete
                                                                    </a>
                                                                </c:if>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
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

    <!-- Page level plugins -->
    <script src="${pageContext.request.contextPath}/vendor/datatables/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendor/datatables/dataTables.bootstrap4.min.js"></script>

    <script>
        $(document).ready(function() {
            $('#dataTable').DataTable({
                "order": [[ 5, "asc" ]],
                "pageLength": 10
            });
        });
    </script>

</body>

</html>
