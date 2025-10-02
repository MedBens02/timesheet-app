<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Validate Timesheets - Timesheet Management</title>
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
                    <h1 class="h3 mb-4 text-gray-800">Validate Timesheets</h1>
                    <c:choose>
                        <c:when test="${empty timesheets}">
                            <div class="alert alert-info">No timesheets pending validation</div>
                        </c:when>
                        <c:otherwise>
                            <div class="card shadow">
                                <div class="card-body">
                                    <table class="table table-bordered" id="dataTable">
                                        <thead>
                                            <tr>
                                                <th>Employee</th>
                                                <th>Week</th>
                                                <th>Total Hours</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${timesheets}" var="ts">
                                                <tr>
                                                    <td>${ts.user.fullName}</td>
                                                    <td>${ts.weekStartDate} - ${ts.weekEndDate}</td>
                                                    <td>${ts.totalHours}h</td>
                                                    <td><span class="badge badge-warning">Submitted</span></td>
                                                    <td>
                                                        <form action="${pageContext.request.contextPath}/timesheet/validate" method="post" style="display:inline;">
                                                            <input type="hidden" name="id" value="${ts.id}">
                                                            <button type="submit" class="btn btn-success btn-sm">
                                                                <i class="fas fa-check"></i> Validate
                                                            </button>
                                                        </form>
                                                        <button type="button" class="btn btn-danger btn-sm" data-toggle="modal" data-target="#rejectModal${ts.id}">
                                                            <i class="fas fa-times"></i> Reject
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <jsp:include page="../includes/footer.jsp" />
        </div>
    </div>
    <jsp:include page="../includes/logout-modal.jsp" />
    <jsp:include page="../includes/scripts.jsp" />
    <script src="${pageContext.request.contextPath}/vendor/datatables/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendor/datatables/dataTables.bootstrap4.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#dataTable').DataTable();
        });
    </script>
</body>
</html>
