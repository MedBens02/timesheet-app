<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Assign Employees - ${project.name} - Timesheet Management</title>
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
                        <div>
                            <h1 class="h3 mb-0 text-gray-800">Assign Employees to Project</h1>
                            <p class="text-gray-600 mb-0">${project.name}</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/project/list" class="d-none d-sm-inline-block btn btn-sm btn-secondary shadow-sm">
                            <i class="fas fa-arrow-left fa-sm text-white-50"></i> Back to Projects
                        </a>
                    </div>

                    <!-- Info Alert -->
                    <div class="alert alert-info alert-dismissible fade show" role="alert">
                        <i class="fas fa-info-circle"></i> <strong>How it works:</strong>
                        Select employees from the list below to assign them to this project.
                        Assigned employees will be able to view the project and its tasks on their dashboard.
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>

                    <!-- Employees Assignment Card -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Select Employees</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty allEmployees}">
                                    <div class="text-center text-gray-500 py-5">
                                        <i class="fas fa-users fa-4x mb-3"></i>
                                        <p class="h5">No employees available to assign</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/project/save-assignments" method="post" id="assignmentForm">
                                        <input type="hidden" name="projectId" value="${project.id}">

                                        <!-- Search Box -->
                                        <div class="form-group">
                                            <div class="input-group">
                                                <div class="input-group-prepend">
                                                    <span class="input-group-text"><i class="fas fa-search"></i></span>
                                                </div>
                                                <input type="text"
                                                       class="form-control"
                                                       id="searchInput"
                                                       placeholder="Search employees by name or email..."
                                                       onkeyup="filterEmployees()">
                                            </div>
                                        </div>

                                        <!-- Quick Actions -->
                                        <div class="mb-3">
                                            <button type="button" class="btn btn-sm btn-outline-primary mr-2" onclick="selectAll()">
                                                <i class="fas fa-check-double"></i> Select All
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-secondary" onclick="deselectAll()">
                                                <i class="fas fa-times"></i> Deselect All
                                            </button>
                                        </div>

                                        <!-- Selection Summary -->
                                        <div class="alert alert-light border mb-3" role="alert">
                                            <strong class="text-primary"><span id="selectedCount">0</span> employee(s) selected</strong>
                                        </div>

                                        <!-- Employees Grid -->
                                        <div class="row" id="employeesGrid">
                                            <c:forEach items="${allEmployees}" var="employee">
                                                <c:set var="isAssigned" value="${false}" />
                                                <c:forEach items="${assignedEmployees}" var="assigned">
                                                    <c:if test="${assigned.id == employee.id}">
                                                        <c:set var="isAssigned" value="${true}" />
                                                    </c:if>
                                                </c:forEach>

                                                <div class="col-md-6 col-lg-4 mb-3">
                                                    <div class="card employee-card ${isAssigned ? 'border-primary' : ''}"
                                                         data-name="${employee.fullName.toLowerCase()}"
                                                         data-email="${employee.email.toLowerCase()}">
                                                        <div class="card-body">
                                                            <div class="custom-control custom-checkbox">
                                                                <input type="checkbox"
                                                                       class="custom-control-input"
                                                                       name="employeeIds"
                                                                       value="${employee.id}"
                                                                       id="emp_${employee.id}"
                                                                       ${isAssigned ? 'checked' : ''}
                                                                       onchange="updateCard(this)">
                                                                <label class="custom-control-label" for="emp_${employee.id}">
                                                                    <div class="font-weight-bold text-gray-800">${employee.fullName}</div>
                                                                    <small class="text-gray-600">${employee.email}</small>
                                                                </label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <!-- Form Actions -->
                                        <hr>
                                        <div class="form-group mb-0">
                                            <button type="submit" class="btn btn-primary btn-lg">
                                                <i class="fas fa-save"></i> Save Assignments
                                            </button>
                                            <a href="${pageContext.request.contextPath}/project/list" class="btn btn-secondary btn-lg ml-2">
                                                <i class="fas fa-times"></i> Cancel
                                            </a>
                                        </div>
                                    </form>
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

    <!-- Employee Selection Script -->
    <style>
        .employee-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .employee-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(78, 115, 223, 0.2) !important;
        }

        .employee-card.border-primary {
            background: linear-gradient(135deg, rgba(78, 115, 223, 0.05) 0%, rgba(78, 115, 223, 0.1) 100%);
        }
    </style>

    <script>
        function updateCard(checkbox) {
            const card = checkbox.closest('.employee-card');
            if (checkbox.checked) {
                card.classList.add('border-primary');
            } else {
                card.classList.remove('border-primary');
            }
            updateSelectionCount();
        }

        function updateSelectionCount() {
            const count = document.querySelectorAll('input[name="employeeIds"]:checked').length;
            document.getElementById('selectedCount').textContent = count;
        }

        function selectAll() {
            const checkboxes = document.querySelectorAll('input[name="employeeIds"]');
            checkboxes.forEach(cb => {
                if (!cb.checked) {
                    cb.checked = true;
                    updateCard(cb);
                }
            });
        }

        function deselectAll() {
            const checkboxes = document.querySelectorAll('input[name="employeeIds"]:checked');
            checkboxes.forEach(cb => {
                cb.checked = false;
                updateCard(cb);
            });
        }

        function filterEmployees() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const cards = document.querySelectorAll('.employee-card');

            cards.forEach(card => {
                const name = card.getAttribute('data-name');
                const email = card.getAttribute('data-email');
                const parent = card.closest('.col-md-6');

                if (name.includes(searchTerm) || email.includes(searchTerm)) {
                    parent.style.display = '';
                } else {
                    parent.style.display = 'none';
                }
            });
        }

        // Click on card to toggle checkbox
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.employee-card').forEach(card => {
                card.addEventListener('click', function(e) {
                    if (e.target.type !== 'checkbox') {
                        const checkbox = this.querySelector('input[type="checkbox"]');
                        checkbox.checked = !checkbox.checked;
                        updateCard(checkbox);
                    }
                });
            });

            // Initialize selection count on page load
            updateSelectionCount();
        });
    </script>

</body>

</html>
