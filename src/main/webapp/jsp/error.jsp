<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Error - Timesheet Management</title>
    <jsp:include page="includes/head.jsp" />
</head>

<body id="page-top">

    <div id="wrapper">
        <jsp:include page="includes/sidebar.jsp" />

        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="includes/topbar.jsp" />

                <div class="container-fluid">
                    <div class="text-center mt-5">
                        <div class="error mx-auto" data-text="Error">
                            <i class="fas fa-exclamation-triangle fa-5x text-warning mb-4"></i>
                        </div>
                        <p class="lead text-gray-800 mb-5">Something went wrong!</p>
                        <p class="text-gray-500 mb-4">
                            <c:choose>
                                <c:when test="${not empty requestScope.error}">
                                    ${requestScope.error}
                                </c:when>
                                <c:when test="${not empty pageContext.exception}">
                                    ${pageContext.exception.message}
                                </c:when>
                                <c:otherwise>
                                    An unexpected error occurred. Please try again.
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>
                    </div>
                </div>

            </div>

            <jsp:include page="includes/footer.jsp" />
        </div>
    </div>

    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <jsp:include page="includes/logout-modal.jsp" />
    <jsp:include page="includes/scripts.jsp" />

</body>

</html>
