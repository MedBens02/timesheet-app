<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>View Timesheet - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
</head>
<body id="page-top">
    <div id="wrapper">
        <jsp:include page="../includes/sidebar.jsp" />
        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="../includes/topbar.jsp" />
                <div class="container-fluid">
                    <h1 class="h3 mb-4 text-gray-800">Timesheet Details</h1>
                    <div class="card shadow">
                        <div class="card-header">
                            <h6 class="m-0 font-weight-bold text-primary">Week ${timesheet.weekStartDate} to ${timesheet.weekEndDate}</h6>
                        </div>
                        <div class="card-body">
                            <p><strong>Employee:</strong> ${timesheet.user.fullName}</p>
                            <p><strong>Total Hours:</strong> ${timesheet.totalHours}h</p>
                            <p><strong>Status:</strong> 
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
                            </p>
                            <a href="${pageContext.request.contextPath}/timesheet/list" class="btn btn-secondary">Back to List</a>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="../includes/footer.jsp" />
        </div>
    </div>
    <jsp:include page="../includes/logout-modal.jsp" />
    <jsp:include page="../includes/scripts.jsp" />
</body>
</html>
