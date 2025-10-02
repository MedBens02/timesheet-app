<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>Register Hours - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
</head>

<body id="page-top">

    <div id="wrapper">
        <jsp:include page="../includes/sidebar.jsp" />

        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="../includes/topbar.jsp" />

                <div class="container-fluid">

                    <h1 class="h3 mb-4 text-gray-800">Register Hours</h1>

                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Week ${weekStart} to ${weekEnd}</h6>
                        </div>
                        <div class="card-body">
                            <form action="${pageContext.request.contextPath}/timesheet/create" method="post">
                                <input type="hidden" name="weekStart" value="${weekStart}">

                                <c:choose>
                                    <c:when test="${empty activeTasks}">
                                        <div class="alert alert-info">
                                            <i class="fas fa-info-circle"></i> No active tasks assigned. Please contact your project manager.
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>Task</th>
                                                        <th>Mon</th>
                                                        <th>Tue</th>
                                                        <th>Wed</th>
                                                        <th>Thu</th>
                                                        <th>Fri</th>
                                                        <th>Sat</th>
                                                        <th>Sun</th>
                                                        <th>Total</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${activeTasks}" var="task">
                                                        <tr>
                                                            <td>
                                                                <strong>${task.name}</strong><br>
                                                                <small class="text-muted">${task.project.name}</small>
                                                                <input type="hidden" name="taskId[]" value="${task.id}">
                                                            </td>
                                                            <c:forEach var="day" begin="0" end="6">
                                                                <td>
                                                                    <input type="number"
                                                                           class="form-control form-control-sm task-hours"
                                                                           name="hours_${task.id}_${day}"
                                                                           data-task="${task.id}"
                                                                           min="0"
                                                                           max="24"
                                                                           value="0"
                                                                           style="width: 60px;">
                                                                </td>
                                                            </c:forEach>
                                                            <td>
                                                                <span class="badge badge-primary task-total" data-task="${task.id}">0h</span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                    <tr class="table-active">
                                                        <th>Daily Total</th>
                                                        <th><span id="day-0-total">0h</span></th>
                                                        <th><span id="day-1-total">0h</span></th>
                                                        <th><span id="day-2-total">0h</span></th>
                                                        <th><span id="day-3-total">0h</span></th>
                                                        <th><span id="day-4-total">0h</span></th>
                                                        <th><span id="day-5-total">0h</span></th>
                                                        <th><span id="day-6-total">0h</span></th>
                                                        <th><span class="badge badge-success" id="week-total">0h</span></th>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>

                                        <div class="mt-3">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save"></i> Save Timesheet
                                            </button>
                                            <a href="${pageContext.request.contextPath}/timesheet/list" class="btn btn-secondary">
                                                <i class="fas fa-times"></i> Cancel
                                            </a>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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

    <script>
        $(document).ready(function() {
            $('.task-hours').on('input', function() {
                calculateTotals();
            });

            function calculateTotals() {
                // Calculate task totals
                $('.task-total').each(function() {
                    var taskId = $(this).data('task');
                    var total = 0;
                    $('input[data-task="' + taskId + '"]').each(function() {
                        total += parseInt($(this).val()) || 0;
                    });
                    $(this).text(total + 'h');
                });

                // Calculate daily totals
                for (var day = 0; day < 7; day++) {
                    var dayTotal = 0;
                    $('input[name$="_' + day + '"]').each(function() {
                        dayTotal += parseInt($(this).val()) || 0;
                    });
                    $('#day-' + day + '-total').text(dayTotal + 'h');
                }

                // Calculate week total
                var weekTotal = 0;
                $('.task-hours').each(function() {
                    weekTotal += parseInt($(this).val()) || 0;
                });
                $('#week-total').text(weekTotal + 'h');

                if (weekTotal > 40) {
                    $('#week-total').removeClass('badge-success').addClass('badge-warning');
                } else {
                    $('#week-total').removeClass('badge-warning').addClass('badge-success');
                }
            }

            calculateTotals();
        });
    </script>

</body>

</html>
