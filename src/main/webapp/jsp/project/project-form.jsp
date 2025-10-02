<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title><c:choose><c:when test="${action == 'edit'}">Edit Project</c:when><c:otherwise>Create Project</c:otherwise></c:choose> - Timesheet Management</title>
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
                        <h1 class="h3 mb-0 text-gray-800">
                            <c:choose>
                                <c:when test="${action == 'edit'}">Edit Project</c:when>
                                <c:otherwise>Create New Project</c:otherwise>
                            </c:choose>
                        </h1>
                        <a href="${pageContext.request.contextPath}/project/list" class="d-none d-sm-inline-block btn btn-sm btn-secondary shadow-sm">
                            <i class="fas fa-arrow-left fa-sm text-white-50"></i> Back to Projects
                        </a>
                    </div>

                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle"></i> ${error}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <!-- Info Box for New Projects -->
                    <c:if test="${action != 'edit'}">
                        <div class="alert alert-info alert-dismissible fade show" role="alert">
                            <i class="fas fa-info-circle"></i> <strong>Project Workflow:</strong>
                            New projects start with status "En attente" (Awaiting Validation).
                            After creation, you can request validation from an administrator.
                            Once validated, you can create tasks and assign employees.
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <!-- Project Form Card -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Project Information</h6>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/project/save" method="post" onsubmit="return validateForm()">
                                <input type="hidden" name="action" value="${action}">
                                <c:if test="${action == 'edit' && not empty project}">
                                    <input type="hidden" name="projectId" value="${project.id}">
                                </c:if>

                                <!-- Project Name -->
                                <div class="form-group">
                                    <label for="name" class="font-weight-bold">
                                        Project Name <span class="text-danger">*</span>
                                    </label>
                                    <input type="text"
                                           class="form-control form-control-lg"
                                           id="name"
                                           name="name"
                                           value="${not empty project ? project.name : ''}"
                                           required
                                           maxlength="100"
                                           placeholder="e.g., E-commerce Platform Development">
                                    <small class="form-text text-muted">Maximum 100 characters</small>
                                </div>

                                <!-- Client Name -->
                                <div class="form-group">
                                    <label for="clientName" class="font-weight-bold">Client Name</label>
                                    <input type="text"
                                           class="form-control"
                                           id="clientName"
                                           name="clientName"
                                           value="${not empty project && not empty project.clientName ? project.clientName : ''}"
                                           maxlength="200"
                                           placeholder="e.g., ABC Corporation">
                                    <small class="form-text text-muted">Optional - Name of the client for this project</small>
                                </div>

                                <!-- Description -->
                                <div class="form-group">
                                    <label for="description" class="font-weight-bold">Description</label>
                                    <textarea class="form-control"
                                              id="description"
                                              name="description"
                                              rows="4"
                                              placeholder="Describe the project objectives, scope, and deliverables...">${not empty project && not empty project.description ? project.description : ''}</textarea>
                                </div>

                                <!-- Project Manager Selection (Admin only) -->
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser.role.toString() == 'ADMIN' && not empty managers}">
                                        <div class="form-group">
                                            <label for="managerId" class="font-weight-bold">
                                                Project Manager <span class="text-danger">*</span>
                                            </label>
                                            <select class="form-control" id="managerId" name="managerId" required>
                                                <option value="">-- Select Manager --</option>
                                                <c:forEach items="${managers}" var="manager">
                                                    <option value="${manager.id}"
                                                        ${action == 'edit' && not empty project && project.manager.id == manager.id ? 'selected' : ''}>
                                                        ${manager.fullName} (${manager.email})
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <small class="form-text text-muted">Assign a project manager to oversee this project</small>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="alert alert-light border" role="alert">
                                            <strong><i class="fas fa-user-tie"></i> Project Manager:</strong>
                                            ${sessionScope.currentUser.fullName} (You)
                                        </div>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Dates Row -->
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="startDate" class="font-weight-bold">Start Date</label>
                                            <input type="date"
                                                   class="form-control"
                                                   id="startDate"
                                                   name="startDate"
                                                   value="${action == 'edit' && not empty project && not empty project.startDate ? project.startDate : ''}">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="endDate" class="font-weight-bold">End Date</label>
                                            <input type="date"
                                                   class="form-control"
                                                   id="endDate"
                                                   name="endDate"
                                                   value="${action == 'edit' && not empty project && not empty project.endDate ? project.endDate : ''}">
                                        </div>
                                    </div>
                                </div>

                                <!-- Estimation Row -->
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="estimatedHours" class="font-weight-bold">Estimated Hours</label>
                                            <div class="input-group">
                                                <input type="number"
                                                       class="form-control"
                                                       id="estimatedHours"
                                                       name="estimatedHours"
                                                       value="${action == 'edit' && not empty project ? project.estimatedHours : ''}"
                                                       min="0"
                                                       step="1"
                                                       placeholder="0">
                                                <div class="input-group-append">
                                                    <span class="input-group-text">hours</span>
                                                </div>
                                            </div>
                                            <small class="form-text text-muted">Total estimated project hours</small>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="estimatedCost" class="font-weight-bold">Estimated Cost</label>
                                            <div class="input-group">
                                                <div class="input-group-prepend">
                                                    <span class="input-group-text">$</span>
                                                </div>
                                                <input type="number"
                                                       class="form-control"
                                                       id="estimatedCost"
                                                       name="estimatedCost"
                                                       value="${action == 'edit' && not empty project ? project.estimatedCost : ''}"
                                                       min="0"
                                                       step="0.01"
                                                       placeholder="0.00">
                                            </div>
                                            <small class="form-text text-muted">Budget allocation for this project</small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Form Actions -->
                                <hr>
                                <div class="form-group mb-0">
                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="fas fa-save"></i>
                                        <c:choose>
                                            <c:when test="${action == 'edit'}">Update Project</c:when>
                                            <c:otherwise>Create Project</c:otherwise>
                                        </c:choose>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/project/list" class="btn btn-secondary btn-lg ml-2">
                                        <i class="fas fa-times"></i> Cancel
                                    </a>
                                </div>
                            </form>
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

    <!-- Form Validation Script -->
    <script>
        function validateForm() {
            const startDate = document.getElementById('startDate').value;
            const endDate = document.getElementById('endDate').value;

            if (startDate && endDate && new Date(endDate) < new Date(startDate)) {
                alert('End date must be after start date');
                return false;
            }

            return true;
        }

        // Set minimum end date based on start date
        document.getElementById('startDate').addEventListener('change', function() {
            const endDateInput = document.getElementById('endDate');
            endDateInput.min = this.value;
        });
    </script>

</body>

</html>
