<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title><c:choose><c:when test="${action == 'edit'}">Edit Task</c:when><c:otherwise>Create Task</c:otherwise></c:choose> - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
</head>

<body id="page-top">

    <div id="wrapper">
        <jsp:include page="../includes/sidebar.jsp" />

        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="../includes/topbar.jsp" />

                <div class="container-fluid">

                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">
                            <c:choose>
                                <c:when test="${action == 'edit'}">Edit Task</c:when>
                                <c:otherwise>Create New Task</c:otherwise>
                            </c:choose>
                        </h1>
                        <a href="${pageContext.request.contextPath}/task/list" class="d-none d-sm-inline-block btn btn-sm btn-secondary shadow-sm">
                            <i class="fas fa-arrow-left fa-sm text-white-50"></i> Back to Tasks
                        </a>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle"></i> ${error}
                            <button type="button" class="close" data-dismiss="alert">
                                <span>&times;</span>
                            </button>
                        </div>
                    </c:if>

                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Task Information</h6>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/task/save" method="post">
                                <input type="hidden" name="action" value="${action}">
                                <c:if test="${action == 'edit' && not empty task}">
                                    <input type="hidden" name="taskId" value="${task.id}">
                                </c:if>

                                <div class="form-group">
                                    <label for="name" class="font-weight-bold">
                                        Task Name <span class="text-danger">*</span>
                                    </label>
                                    <input type="text"
                                           class="form-control form-control-lg"
                                           id="name"
                                           name="name"
                                           value="${not empty task ? task.name : ''}"
                                           required
                                           maxlength="200">
                                </div>

                                <div class="form-group">
                                    <label for="description" class="font-weight-bold">Description</label>
                                    <textarea class="form-control"
                                              id="description"
                                              name="description"
                                              rows="4">${not empty task && not empty task.description ? task.description : ''}</textarea>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="projectId" class="font-weight-bold">
                                                Project <span class="text-danger">*</span>
                                            </label>
                                            <select class="form-control" id="projectId" name="projectId" required>
                                                <option value="">-- Select Project --</option>
                                                <c:forEach items="${projects}" var="project">
                                                    <option value="${project.id}"
                                                        ${action == 'edit' && not empty task && task.project.id == project.id ? 'selected' : ''}>
                                                        ${project.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="assignedToId" class="font-weight-bold">
                                                Assign To <span class="text-danger">*</span>
                                            </label>
                                            <select class="form-control" id="assignedToId" name="assignedToId" required>
                                                <option value="">-- Select Employee --</option>
                                                <c:forEach items="${employees}" var="employee">
                                                    <option value="${employee.id}"
                                                        ${action == 'edit' && not empty task && task.assignedTo.id == employee.id ? 'selected' : ''}>
                                                        ${employee.fullName}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label for="priority" class="font-weight-bold">Priority</label>
                                            <select class="form-control" id="priority" name="priority">
                                                <option value="LOW" ${action == 'edit' && task.priority == 'LOW' ? 'selected' : ''}>Low</option>
                                                <option value="MEDIUM" ${action == 'edit' && task.priority == 'MEDIUM' ? 'selected' : 'selected'}>Medium</option>
                                                <option value="HIGH" ${action == 'edit' && task.priority == 'HIGH' ? 'selected' : ''}>High</option>
                                                <option value="URGENT" ${action == 'edit' && task.priority == 'URGENT' ? 'selected' : ''}>Urgent</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label for="status" class="font-weight-bold">Status</label>
                                            <select class="form-control" id="status" name="status">
                                                <option value="A_FAIRE" ${action == 'edit' && task.status == 'A_FAIRE' ? 'selected' : 'selected'}>À faire</option>
                                                <option value="EN_COURS" ${action == 'edit' && task.status == 'EN_COURS' ? 'selected' : ''}>En cours</option>
                                                <option value="VALIDEE" ${action == 'edit' && task.status == 'VALIDEE' ? 'selected' : ''}>Validée</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label for="dueDate" class="font-weight-bold">Due Date</label>
                                            <input type="date"
                                                   class="form-control"
                                                   id="dueDate"
                                                   name="dueDate"
                                                   value="${action == 'edit' && not empty task && not empty task.dueDate ? task.dueDate : ''}">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="estimatedHours" class="font-weight-bold">Estimated Hours</label>
                                            <div class="input-group">
                                                <input type="number"
                                                       class="form-control"
                                                       id="estimatedHours"
                                                       name="estimatedHours"
                                                       value="${action == 'edit' && not empty task ? task.estimatedHours : ''}"
                                                       min="0"
                                                       step="0.5">
                                                <div class="input-group-append">
                                                    <span class="input-group-text">hours</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="progressPercentage" class="font-weight-bold">Progress (%)</label>
                                            <input type="number"
                                                   class="form-control"
                                                   id="progressPercentage"
                                                   name="progressPercentage"
                                                   value="${action == 'edit' && not empty task ? task.progressPercentage : 0}"
                                                   min="0"
                                                   max="100"
                                                   step="5">
                                        </div>
                                    </div>
                                </div>

                                <hr>
                                <div class="form-group mb-0">
                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="fas fa-save"></i>
                                        <c:choose>
                                            <c:when test="${action == 'edit'}">Update Task</c:when>
                                            <c:otherwise>Create Task</c:otherwise>
                                        </c:choose>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/task/list" class="btn btn-secondary btn-lg ml-2">
                                        <i class="fas fa-times"></i> Cancel
                                    </a>
                                </div>
                            </form>
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

</body>

</html>
