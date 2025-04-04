<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
if (session == null || session.getAttribute("user") == null || (!"admin".equals(session.getAttribute("role")) && !"hr".equals(session.getAttribute("role")))) {
    response.sendRedirect("login.jsp");
    return;
}

String userEmail = (String) session.getAttribute("user");
String userRole = (String) session.getAttribute("role");
byte[] userImage = null;
String userName = "";

try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT name, profile_image FROM users WHERE email = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, userEmail);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            userName = rs.getString("name");
            userImage = rs.getBytes("profile_image");
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
    userImage = null;
}

// Format current date and time
SimpleDateFormat sdf = new SimpleDateFormat("EEE MMM dd HH:mm:ss z yyyy");
String currentDate = sdf.format(new Date());

// Fetch Employee Data with Joins (for HR and Admin)
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
try {
    conn = DBConnection.getConnection();
    pstmt = conn.prepareStatement("SELECT e.empId, e.firstName, e.lastName, q.degree AS qualification, p.position " +
                                 "FROM employee e " +
                                 "LEFT JOIN qualification q ON e.empId = q.empId " +
                                 "LEFT JOIN position p ON e.empId = p.empId");
    rs = pstmt.executeQuery();
} catch (SQLException e) {
    e.printStackTrace();
}

// Fetch HR Users (for Admin only)
PreparedStatement hrStmt = null;
ResultSet hrRs = null;
if ("admin".equals(userRole)) {
    try {
        hrStmt = conn.prepareStatement("SELECT name, email, role, profile_image FROM users WHERE role = 'hr'");
        hrRs = hrStmt.executeQuery();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Reports</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/view_reports_style.css">
</head>
<body>

<!-- Header (Matching Admin/HR Dashboard) -->
<header class="report-header">
    <div class="header-content">
        <div class="logo-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-unity logo-icon" viewBox="0 0 16 16">
                <path d="M15 11.2V3.733L8.61 0v2.867l2.503 1.466c.099.067.099.2 0 .234L8.148 6.3c-.099.067-.197.033-.263 0L4.92 4.567c-.099-.034-.099-.2 0-.234l2.504-1.466V0L1 3.733V11.2v-.033.033l2.438-1.433V6.833c0-.1.131-.166.197-.133L6.6 8.433c.099.067.132.134.132.234v3.466c0 .1-.132.167-.198.134L4.031 10.8l-2.438 1.433L7.983 16l6.391-3.733-2.438-1.434L9.434 12.3c-.099.067-.198 0-.198-.133V8.7c0-.1.066-.2.132-.233l2.965-1.734c.099-.066.197 0 .197.134V9.8z"/>
            </svg>
            <span class="logo-text">PathForge</span>
        </div>
        <div class="user-profile">
            <img src="<%= userImage != null ? "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(userImage) : "assets/images/profile.jpg" %>" alt="User Profile" class="profile-image">
            <div class="user-details">
                <span class="user-name"><%= userName %></span>
                <span class="user-email"><%= userEmail %></span>
                <span class="user-role">(<%= userRole != null ? userRole.toUpperCase() : "User" %>)</span>
                <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- Page Content -->
<main class="content">
    <!-- Welcome Section (Matching Admin/HR Dashboard) -->
    <div class="welcome-section">
        <h1 class="content-title">Welcome, <%= userName %></h1>
        <p class="content-subtitle">View employee reports below.</p>
    </div>
    <div class="date-section">
        <span class="current-date"><%= currentDate %></span>
    </div>

    <!-- Employee Report Table (Visible to both HR and Admin) -->
    <div class="report-section">
        <h2 class="section-title">Employee Report</h2>
        <div class="table-container">
            <table class="report-table">
                <thead>
                    <tr>
                        <th>Employee ID</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Qualification</th>
                        <th>Position</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (!rs.isBeforeFirst()) {
                    %>
                    <tr>
                        <td colspan="5" class="no-data">No employees found.</td>
                    </tr>
                    <%
                    } else {
                        while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("empId") %></td>
                        <td><%= rs.getString("firstName") %></td>
                        <td><%= rs.getString("lastName") %></td>
                        <td><%= rs.getString("qualification") != null ? rs.getString("qualification") : "N/A" %></td>
                        <td><%= rs.getString("position") != null ? rs.getString("position") : "N/A" %></td>
                    </tr>
                    <%
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- HR Users Report Table (Visible to Admin only) -->
    <% if ("admin".equals(userRole)) { %>
    <div class="report-section">
        <h2 class="section-title">HR Users Report</h2>
        <div class="table-container">
            <table class="report-table">
                <thead>
                    <tr>
                        <th>Profile Picture</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (!hrRs.isBeforeFirst()) {
                    %>
                    <tr>
                        <td colspan="4" class="no-data">No HR users found.</td>
                    </tr>
                    <%
                    } else {
                        while (hrRs.next()) {
                            String hrName = hrRs.getString("name");
                            String hrEmail = hrRs.getString("email");
                            String hrRole = hrRs.getString("role");
                            byte[] hrProfileImage = hrRs.getBytes("profile_image");
                            String hrImageBase64 = hrProfileImage != null ? Base64.getEncoder().encodeToString(hrProfileImage) : null;
                    %>
                    <tr>
                        <td>
                            <img src="<%= hrImageBase64 != null ? "data:image/jpeg;base64," + hrImageBase64 : "assets/images/profile.jpg" %>" alt="Profile Picture" class="table-profile-image">
                        </td>
                        <td><%= hrName %></td>
                        <td><%= hrEmail %></td>
                        <td><%= hrRole != null ? hrRole.toUpperCase() : "N/A" %></td>
                    </tr>
                    <%
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</main>

<!-- Footer (Matching Admin/HR Dashboard) -->
<footer class="report-footer">
    <p>© 2025 PathForge. All rights reserved.</p>
</footer>

<%
if (rs != null) rs.close();
if (pstmt != null) pstmt.close();
if (hrRs != null) hrRs.close();
if (hrStmt != null) hrStmt.close();
if (conn != null) conn.close();
%>
</body>
</html>