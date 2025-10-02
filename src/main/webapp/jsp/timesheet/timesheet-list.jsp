<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Timesheets - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
    <link href="${pageContext.request.contextPath}/vendor/datatables/dataTables.bootstrap4.min.css" rel="stylesheet">
</head>

<body id="page-top">

    <div id="wrapper">
        <jsp:include page="../includes/sidebar.jsp" />

        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="../includes/topbar.jsp" />

                <div class="container-fluid">

                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">My Timesheets</h1>
                        <a href="${pageContext.request.contextPath}/timesheet/create" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm">
                            <i class="fas fa-plus fa-sm text-white-50"></i> Create Timesheet
                        </a>
                    </div>

                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle"></i> ${sessionScope.successMessage}
                            <button type="button" class="close" data-dismiss="alert">
                                <span>&times;</span>
                            </button>
                        </div>
                        <c:remove var="successMessage" scope="session"/>
                    </c:if>

                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Timesheet History</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty timesheets}">
                                    <div class="text-center text-gray-500 py-5">
                                        <i class="fas fa-calendar-alt fa-4x mb-3"></i>
                                        <p class="h5">No Timesheets Found</p>
                                        <a href="${pageContext.request.contextPath}/timesheet/create" class="btn btn-primary mt-3">
                                            <i class="fas fa-plus"></i> Create Your First Timesheet
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                            <thead>
                                                <tr>
                                                    <th>Week</th>
                                                    <th>Period</th>
                                                    <th>Total Hours</th>
                                                    <th>Regular Hours</th>
                                                    <th>Overtime Hours</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${timesheets}" var="timesheet">
                                                    <tr>
                                                        <td>Week ${timesheet.weekNumber}</td>
                                                        <td>
                                                            ${timesheet.weekStartDate} - ${timesheet.weekEndDate}
                                                        </td>
                                                        <td>
                                                            <strong>${timesheet.totalHours}h</strong>
                                                            <c:if test="${timesheet.totalHours > 40}">
                                                                <span class="badge badge-warning badge-sm ml-1">Over 40h</span>
                                                            </c:if>
                                                        </td>
                                                        <td>${timesheet.regularHours}h</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${timesheet.overtimeHours > 0}">
                                                                    <span class="text-warning font-weight-bold">${timesheet.overtimeHours}h</span>
                                                                </c:when>
                                                                <c:otherwise>0h</c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${timesheet.status == 'DRAFT'}">
                                                                    <span class="badge badge-secondary">Draft</span>
                                                                </c:when>
                                                                <c:when test="${timesheet.status == 'SUBMITTED'}">
                                                                    <span class="badge badge-warning">Submitted</span>
                                                                </c:when>
                                                                <c:when test="${timesheet.status == 'VALIDATED'}">
                                                                    <span class="badge badge-success">Validated</span>
                                                                </c:when>
                                                                <c:when test="${timesheet.status == 'REJECTED'}">
                                                                    <span class="badge badge-danger">Rejected</span>
                                                                </c:when>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="btn-group-vertical btn-group-sm" role="group">
                                                                <a href="${pageContext.request.contextPath}/timesheet/view?id=${timesheet.id}"
                                                                   class="btn btn-info btn-sm mb-1">
                                                                    <i class="fas fa-eye"></i> View
                                                                </a>
                                                                <c:if test="${timesheet.status == 'DRAFT'}">
                                                                    <a href="${pageContext.request.contextPath}/timesheet/edit?id=${timesheet.id}"
                                                                       class="btn btn-secondary btn-sm mb-1">
                                                                        <i class="fas fa-edit"></i> Edit
                                                                    </a>
                                                                    <a href="${pageContext.request.contextPath}/timesheet/submit?id=${timesheet.id}"
                                                                       class="btn btn-primary btn-sm mb-1"
                                                                       onclick="return confirm('Submit this timesheet for validation?')">
                                                                        <i class="fas fa-paper-plane"></i> Submit
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

            </div>

            <jsp:include page="../includes/footer.jsp" />
        </div>
    </div>

    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <jsp:include page="../includes/logout-modal.jsp" />
    <jsp:include page="../includes/scripts.jsp" />

    <script src="${pageContext.request.contextPath}/vendor/datatables/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendor/datatables/dataTables.bootstrap4.min.js"></script>

    <script>
        $(document).ready(function() {
            $('#dataTable').DataTable({
                "order": [[ 1, "desc" ]],
                "pageLength": 10
            });
        });
    </script>

</body>

</html>
