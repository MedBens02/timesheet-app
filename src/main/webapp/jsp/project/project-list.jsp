<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Projects - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />

    <!-- Custom styles for DataTables -->
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
                        <h1 class="h3 mb-0 text-gray-800">Project Management</h1>
                        <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN' || sessionScope.currentUser.role == 'PROJECT_MANAGER'}">
                            <a href="${pageContext.request.contextPath}/project/create" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm">
                                <i class="fas fa-plus fa-sm text-white-50"></i> Create New Project
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
                            <h6 class="m-0 font-weight-bold text-primary">Filter Projects</h6>
                        </div>
                        <div class="card-body">
                            <form method="get" action="${pageContext.request.contextPath}/project/list" class="form-inline">
                                <label class="mr-2">Status:</label>
                                <select name="status" class="form-control form-control-sm mr-3" onchange="this.form.submit()">
                                    <option value="">All Statuses</option>
                                    <option value="EN_ATTENTE" ${param.status == 'EN_ATTENTE' ? 'selected' : ''}>En attente</option>
                                    <option value="VALIDE" ${param.status == 'VALIDE' ? 'selected' : ''}>Validé</option>
                                    <option value="ACTIF" ${param.status == 'ACTIF' ? 'selected' : ''}>Actif</option>
                                    <option value="TERMINE" ${param.status == 'TERMINE' ? 'selected' : ''}>Terminé</option>
                                    <option value="ABANDONNE" ${param.status == 'ABANDONNE' ? 'selected' : ''}>Abandonné</option>
                                </select>
                            </form>
                        </div>
                    </div>

                    <!-- DataTales Example -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">All Projects</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty projects}">
                                    <div class="text-center text-gray-500 py-5">
                                        <i class="fas fa-folder-open fa-4x mb-3"></i>
                                        <p class="h5">No Projects Found</p>
                                        <c:choose>
                                            <c:when test="${sessionScope.currentUser.role.toString() == 'PROJECT_MANAGER'}">
                                                <p>Start by creating your first project!</p>
                                                <a href="${pageContext.request.contextPath}/project/create" class="btn btn-primary mt-3">
                                                    <i class="fas fa-plus"></i> Create Project
                                                </a>
                                            </c:when>
                                            <c:when test="${sessionScope.currentUser.role.toString() == 'ADMIN'}">
                                                <p>No projects have been created yet.</p>
                                            </c:when>
                                            <c:otherwise>
                                                <p>You haven't been assigned to any projects yet.</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                            <thead>
                                                <tr>
                                                    <th>Project</th>
                                                    <th>Manager</th>
                                                    <th>Status</th>
                                                    <th>Progress</th>
                                                    <th>Hours</th>
                                                    <th>Dates</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${projects}" var="project">
                                                    <tr>
                                                        <td>
                                                            <div class="font-weight-bold">${project.name}</div>
                                                            <c:if test="${not empty project.clientName}">
                                                                <small class="text-gray-600">Client: ${project.clientName}</small>
                                                            </c:if>
                                                        </td>
                                                        <td>${project.manager.fullName}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${project.status == 'EN_ATTENTE'}">
                                                                    <span class="badge badge-warning">En attente</span>
                                                                </c:when>
                                                                <c:when test="${project.status == 'VALIDE'}">
                                                                    <span class="badge badge-success">Validé</span>
                                                                </c:when>
                                                                <c:when test="${project.status == 'ACTIF'}">
                                                                    <span class="badge badge-info">Actif</span>
                                                                </c:when>
                                                                <c:when test="${project.status == 'TERMINE'}">
                                                                    <span class="badge badge-secondary">Terminé</span>
                                                                </c:when>
                                                                <c:when test="${project.status == 'ABANDONNE'}">
                                                                    <span class="badge badge-danger">Abandonné</span>
                                                                </c:when>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="progress" style="height: 20px;">
                                                                <div class="progress-bar ${project.progressPercentage >= 100 ? 'bg-success' : project.progressPercentage >= 75 ? 'bg-info' : project.progressPercentage >= 50 ? 'bg-warning' : 'bg-danger'}"
                                                                     role="progressbar"
                                                                     style="width: ${project.progressPercentage}%">
                                                                    <fmt:formatNumber value="${project.progressPercentage}" pattern="0.0"/>%
                                                                </div>
                                                            </div>
                                                            <small class="text-gray-600">${project.actualHours}h / ${project.estimatedHours}h</small>
                                                        </td>
                                                        <td>${project.estimatedHours}h</td>
                                                        <td>
                                                            <c:if test="${not empty project.startDate}">
                                                                ${project.startDate}<br>
                                                            </c:if>
                                                            <c:if test="${not empty project.endDate}">
                                                                to ${project.endDate}
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <div class="btn-group-vertical btn-group-sm" role="group">
                                                                <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN' || (sessionScope.currentUser.role == 'PROJECT_MANAGER' && project.manager.id == sessionScope.currentUser.id)}">
                                                                    <a href="${pageContext.request.contextPath}/project/edit?id=${project.id}" class="btn btn-secondary btn-sm mb-1">
                                                                        <i class="fas fa-edit"></i> Edit
                                                                    </a>

                                                                    <c:if test="${project.status == 'EN_ATTENTE' && sessionScope.currentUser.role == 'PROJECT_MANAGER'}">
                                                                        <a href="${pageContext.request.contextPath}/project/request-validation?id=${project.id}" class="btn btn-warning btn-sm mb-1">
                                                                            <i class="fas fa-paper-plane"></i> Request Validation
                                                                        </a>
                                                                    </c:if>

                                                                    <c:if test="${project.status == 'VALIDE' || project.status == 'ACTIF'}">
                                                                        <a href="${pageContext.request.contextPath}/project/assign-employees?id=${project.id}" class="btn btn-success btn-sm mb-1">
                                                                            <i class="fas fa-users"></i> Assign Employees
                                                                        </a>
                                                                    </c:if>

                                                                    <a href="${pageContext.request.contextPath}/project/delete?id=${project.id}"
                                                                       class="btn btn-danger btn-sm mb-1"
                                                                       onclick="return confirm('Are you sure you want to delete this project?')">
                                                                        <i class="fas fa-trash"></i> Delete
                                                                    </a>
                                                                </c:if>

                                                                <c:if test="${sessionScope.currentUser.role.toString() == 'ADMIN' && project.status == 'EN_ATTENTE'}">
                                                                    <a href="${pageContext.request.contextPath}/project/validate?id=${project.id}" class="btn btn-success btn-sm mb-1">
                                                                        <i class="fas fa-check"></i> Validate
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/project/reject?id=${project.id}"
                                                                       class="btn btn-danger btn-sm mb-1"
                                                                       onclick="return confirm('Are you sure you want to reject this project?')">
                                                                        <i class="fas fa-times"></i> Reject
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

    <!-- DataTables initialization -->
    <script>
        $(document).ready(function() {
            $('#dataTable').DataTable({
                "order": [[ 0, "asc" ]],
                "pageLength": 10,
                "language": {
                    "search": "Search projects:",
                    "lengthMenu": "Show _MENU_ projects per page",
                    "info": "Showing _START_ to _END_ of _TOTAL_ projects",
                    "infoEmpty": "No projects available",
                    "infoFiltered": "(filtered from _MAX_ total projects)",
                    "zeroRecords": "No matching projects found"
                }
            });
        });
    </script>

</body>

</html>
