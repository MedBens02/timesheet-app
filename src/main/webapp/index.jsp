<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Timesheet Management System - Home</title>

    <!-- Custom fonts for this template-->
    <link href="${pageContext.request.contextPath}/vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i" rel="stylesheet">

    <!-- Custom styles for this template-->
    <link href="${pageContext.request.contextPath}/css/sb-admin-2.min.css" rel="stylesheet">

    <style>
        .hero-section {
            background: linear-gradient(135deg, #4e73df 0%, #224abe 100%);
            color: white;
            padding: 100px 0;
            text-align: center;
        }

        .hero-section h1 {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .hero-section p {
            font-size: 1.25rem;
            opacity: 0.9;
            margin-bottom: 2rem;
        }

        .features-section {
            padding: 60px 0;
        }

        .feature-card {
            text-align: center;
            padding: 30px;
            border-radius: 10px;
            transition: transform 0.3s;
        }

        .feature-card:hover {
            transform: translateY(-5px);
        }

        .feature-card i {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .feature-card h4 {
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .cta-section {
            background: #f8f9fc;
            padding: 60px 0;
            text-align: center;
        }

        .cta-section h2 {
            font-weight: 800;
            margin-bottom: 1rem;
        }
    </style>
</head>

<body id="page-top">

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <h1>Timesheet Management System</h1>
            <p>Professional Time Tracking for Projects and Teams</p>
            <div class="mt-4">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-light btn-lg mr-3">
                    <i class="fas fa-sign-in-alt fa-sm"></i> Login
                </a>
                <a href="#features" class="btn btn-outline-light btn-lg">
                    <i class="fas fa-info-circle fa-sm"></i> Learn More
                </a>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="features-section">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="font-weight-bold text-primary">Key Features</h2>
                <p class="text-gray-600">Everything you need to manage projects and track time efficiently</p>
            </div>

            <div class="row">
                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-project-diagram text-primary"></i>
                        <h4>Project Management</h4>
                        <p class="text-gray-600">Create and manage projects with cost estimation, task assignment, and progress tracking.</p>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-tasks text-success"></i>
                        <h4>Task Assignment</h4>
                        <p class="text-gray-600">Assign tasks to team members with priorities, deadlines, and status tracking.</p>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-clock text-info"></i>
                        <h4>Weekly Timesheets</h4>
                        <p class="text-gray-600">Track hours worked per task with automatic overtime calculation at 1.25x rate.</p>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-chart-line text-warning"></i>
                        <h4>Progress Tracking</h4>
                        <p class="text-gray-600">Monitor project progress, task completion, and team productivity in real-time.</p>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-users-cog text-danger"></i>
                        <h4>Role-Based Access</h4>
                        <p class="text-gray-600">Secure access control with Admin, Project Manager, and Employee roles.</p>
                    </div>
                </div>

                <div class="col-lg-4 mb-4">
                    <div class="feature-card shadow-sm">
                        <i class="fas fa-file-invoice-dollar text-secondary"></i>
                        <h4>Pay Calculation</h4>
                        <p class="text-gray-600">Automated salary calculation based on hours worked and overtime rates.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <div class="container">
            <h2 class="text-gray-900">Ready to Get Started?</h2>
            <p class="text-gray-600 mb-4">Log in to access your dashboard and start tracking time.</p>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-lg">
                <i class="fas fa-sign-in-alt fa-sm"></i> Login Now
            </a>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-white py-4 border-top">
        <div class="container">
            <div class="text-center">
                <span class="text-gray-600">&copy; 2024 Timesheet Management System. All rights reserved.</span>
            </div>
        </div>
    </footer>

    <!-- Bootstrap core JavaScript-->
    <script src="${pageContext.request.contextPath}/vendor/jquery/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

    <!-- Core plugin JavaScript-->
    <script src="${pageContext.request.contextPath}/vendor/jquery-easing/jquery.easing.min.js"></script>

    <!-- Custom scripts for all pages-->
    <script src="${pageContext.request.contextPath}/js/sb-admin-2.min.js"></script>

    <!-- Smooth scroll for anchor links -->
    <script>
        $('a[href^="#"]').on('click', function(e) {
            e.preventDefault();
            var target = this.hash;
            $('html, body').animate({
                scrollTop: $(target).offset().top
            }, 800);
        });
    </script>

</body>

</html>
