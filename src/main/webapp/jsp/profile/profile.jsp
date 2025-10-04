<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <title>My Profile - Timesheet Management</title>
    <jsp:include page="../includes/head.jsp" />
</head>

<body id="page-top">

    <div id="wrapper">
        <jsp:include page="../includes/sidebar.jsp" />

        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                <jsp:include page="../includes/topbar.jsp" />

                <div class="container-fluid">

                    <h1 class="h3 mb-4 text-gray-800">My Profile</h1>

                    <!-- Error Message -->
                    <c:if test="${not empty sessionScope.errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${sessionScope.errorMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <c:remove var="errorMessage" scope="session" />
                    </c:if>

                    <!-- Success Message -->
                    <c:if test="${not empty sessionScope.successMessage}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            ${sessionScope.successMessage}
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <c:remove var="successMessage" scope="session" />
                    </c:if>

                    <form action="${pageContext.request.contextPath}/profile/edit" method="post" id="profileForm">
                        <div class="row">
                            <!-- Personal Information Card -->
                            <div class="col-xl-8 col-lg-7">
                                <div class="card shadow mb-4">
                                    <div class="card-header py-3">
                                        <h6 class="m-0 font-weight-bold text-primary">Personal Information</h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="firstName">First Name <span class="text-danger">*</span></label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="firstName"
                                                       name="firstName"
                                                       value="${user.firstName}"
                                                       required
                                                       maxlength="50">
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="lastName">Last Name <span class="text-danger">*</span></label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="lastName"
                                                       name="lastName"
                                                       value="${user.lastName}"
                                                       required
                                                       maxlength="50">
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label for="email">Email Address <span class="text-danger">*</span></label>
                                            <input type="email"
                                                   class="form-control"
                                                   id="email"
                                                   name="email"
                                                   value="${user.email}"
                                                   required
                                                   maxlength="100">
                                            <small class="form-text text-muted">Your email address must be unique.</small>
                                        </div>

                                        <div class="form-row">
                                            <div class="form-group col-md-6">
                                                <label for="username">Username</label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="username"
                                                       value="${user.username}"
                                                       readonly
                                                       disabled>
                                                <small class="form-text text-muted">Username cannot be changed.</small>
                                            </div>
                                            <div class="form-group col-md-6">
                                                <label for="role">Role</label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="role"
                                                       value="${user.role}"
                                                       readonly
                                                       disabled>
                                            </div>
                                        </div>

                                        <c:if test="${user.hourlyRate != null && user.hourlyRate > 0}">
                                            <div class="form-group">
                                                <label for="hourlyRate">Hourly Rate</label>
                                                <input type="text"
                                                       class="form-control"
                                                       id="hourlyRate"
                                                       value="$${user.hourlyRate}"
                                                       readonly
                                                       disabled>
                                                <small class="form-text text-muted">Contact your administrator to update your hourly rate.</small>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <!-- Account Info Sidebar -->
                            <div class="col-xl-4 col-lg-5">
                                <div class="card shadow mb-4">
                                    <div class="card-header py-3">
                                        <h6 class="m-0 font-weight-bold text-primary">Account Information</h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="text-center">
                                            <img class="img-profile rounded-circle mb-3"
                                                 src="${pageContext.request.contextPath}/img/undraw_profile.svg"
                                                 style="width: 120px; height: 120px;">
                                            <h5 class="font-weight-bold">${user.fullName}</h5>
                                            <p class="text-muted">${user.email}</p>
                                        </div>
                                        <hr>
                                        <div class="small">
                                            <p><strong>Role:</strong> ${user.role}</p>
                                            <p><strong>Status:</strong>
                                                <c:choose>
                                                    <c:when test="${user.isActive}">
                                                        <span class="badge badge-success">Active</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">Inactive</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                            <c:if test="${user.createdAt != null}">
                                                <p><strong>Member Since:</strong> ${user.createdAt.toLocalDate()}</p>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Change Password Card -->
                        <div class="row">
                            <div class="col-xl-8 col-lg-7">
                                <div class="card shadow mb-4">
                                    <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                        <h6 class="m-0 font-weight-bold text-primary">Change Password</h6>
                                        <small class="text-muted">Leave blank if you don't want to change password</small>
                                    </div>
                                    <div class="card-body">
                                        <div class="form-group">
                                            <label for="currentPassword">Current Password</label>
                                            <div class="input-group">
                                                <input type="password"
                                                       class="form-control"
                                                       id="currentPassword"
                                                       name="currentPassword"
                                                       autocomplete="current-password">
                                                <div class="input-group-append">
                                                    <button class="btn btn-outline-secondary"
                                                            type="button"
                                                            onclick="togglePassword('currentPassword')">
                                                        <i class="fas fa-eye" id="currentPassword-icon"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label for="newPassword">New Password</label>
                                            <div class="input-group">
                                                <input type="password"
                                                       class="form-control"
                                                       id="newPassword"
                                                       name="newPassword"
                                                       autocomplete="new-password">
                                                <div class="input-group-append">
                                                    <button class="btn btn-outline-secondary"
                                                            type="button"
                                                            onclick="togglePassword('newPassword')">
                                                        <i class="fas fa-eye" id="newPassword-icon"></i>
                                                    </button>
                                                </div>
                                            </div>
                                            <small class="form-text text-muted">
                                                Password must be at least 6 characters and contain uppercase, lowercase, and a digit.
                                            </small>
                                            <div id="passwordStrength" class="mt-2"></div>
                                        </div>

                                        <div class="form-group">
                                            <label for="confirmPassword">Confirm New Password</label>
                                            <div class="input-group">
                                                <input type="password"
                                                       class="form-control"
                                                       id="confirmPassword"
                                                       name="confirmPassword"
                                                       autocomplete="new-password">
                                                <div class="input-group-append">
                                                    <button class="btn btn-outline-secondary"
                                                            type="button"
                                                            onclick="togglePassword('confirmPassword')">
                                                        <i class="fas fa-eye" id="confirmPassword-icon"></i>
                                                    </button>
                                                </div>
                                            </div>
                                            <div id="passwordMatch" class="mt-2"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="row">
                            <div class="col-xl-8 col-lg-7">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-save"></i> Update Profile
                                </button>
                                <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-secondary btn-lg">
                                    <i class="fas fa-times"></i> Cancel
                                </a>
                            </div>
                        </div>
                    </form>

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
        // Toggle password visibility
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const icon = document.getElementById(fieldId + '-icon');

            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Password strength checker
        document.getElementById('newPassword').addEventListener('input', function() {
            const password = this.value;
            const strengthDiv = document.getElementById('passwordStrength');

            if (password.length === 0) {
                strengthDiv.innerHTML = '';
                return;
            }

            let strength = 0;
            let feedback = [];

            if (password.length >= 6) strength++;
            else feedback.push('at least 6 characters');

            if (/[a-z]/.test(password)) strength++;
            else feedback.push('a lowercase letter');

            if (/[A-Z]/.test(password)) strength++;
            else feedback.push('an uppercase letter');

            if (/[0-9]/.test(password)) strength++;
            else feedback.push('a digit');

            if (strength < 4) {
                strengthDiv.innerHTML = '<small class="text-danger">Password must contain: ' + feedback.join(', ') + '</small>';
            } else {
                strengthDiv.innerHTML = '<small class="text-success"><i class="fas fa-check"></i> Password is strong</small>';
            }
        });

        // Password match checker
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = this.value;
            const matchDiv = document.getElementById('passwordMatch');

            if (confirmPassword.length === 0) {
                matchDiv.innerHTML = '';
                return;
            }

            if (newPassword === confirmPassword) {
                matchDiv.innerHTML = '<small class="text-success"><i class="fas fa-check"></i> Passwords match</small>';
            } else {
                matchDiv.innerHTML = '<small class="text-danger"><i class="fas fa-times"></i> Passwords do not match</small>';
            }
        });

        // Form validation
        document.getElementById('profileForm').addEventListener('submit', function(e) {
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            // If any password field is filled, all must be filled
            if ((currentPassword || newPassword || confirmPassword) &&
                (!currentPassword || !newPassword || !confirmPassword)) {
                e.preventDefault();
                alert('If changing password, all password fields must be filled.');
                return false;
            }

            // Validate password match
            if (newPassword && newPassword !== confirmPassword) {
                e.preventDefault();
                alert('New password and confirm password do not match.');
                return false;
            }

            // Validate password strength
            if (newPassword) {
                if (newPassword.length < 6 ||
                    !/[a-z]/.test(newPassword) ||
                    !/[A-Z]/.test(newPassword) ||
                    !/[0-9]/.test(newPassword)) {
                    e.preventDefault();
                    alert('Password must be at least 6 characters and contain uppercase, lowercase, and a digit.');
                    return false;
                }
            }

            return true;
        });
    </script>

</body>

</html>
