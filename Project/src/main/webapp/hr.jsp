<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
String hrEmail = (String) session.getAttribute("user");

// Database Connection for Profile Image and Name
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String message = "";
String profileImageBase64 = null;
String hrName = "";

try {
    conn = DBConnection.getConnection();
    pstmt = conn.prepareStatement("SELECT name, profile_image FROM users WHERE email = ?");
    pstmt.setString(1, hrEmail);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        hrName = rs.getString("name");
        if (rs.getBytes("profile_image") != null) {
            byte[] imageBytes = rs.getBytes("profile_image");
            profileImageBase64 = Base64.getEncoder().encodeToString(imageBytes);
        }
    }
} catch (Exception e) {
    e.printStackTrace();
    profileImageBase64 = null;
} finally {
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
}

// Handle Employee Deletion
if (request.getParameter("delete") != null) {
    String empId = request.getParameter("delete");
    try {
        conn.setAutoCommit(false);
        // Delete from position table
        pstmt = conn.prepareStatement("DELETE FROM position WHERE empId = ?");
        pstmt.setString(1, empId);
        pstmt.executeUpdate();
        // Delete from qualification table
        pstmt = conn.prepareStatement("DELETE FROM qualification WHERE empId = ?");
        pstmt.setString(1, empId);
        pstmt.executeUpdate();
        // Delete from employee table
        pstmt = conn.prepareStatement("DELETE FROM employee WHERE empId = ?");
        pstmt.setString(1, empId);
        pstmt.executeUpdate();
        conn.commit();
        message = "Employee deleted successfully.";
    } catch (Exception e) {
        if (conn != null) conn.rollback();
        e.printStackTrace();
        message = "Error deleting employee.";
    } finally {
        conn.setAutoCommit(true);
    }
}

// Fetch Employee Data with Joins
try {
    pstmt = conn.prepareStatement("SELECT e.empId, e.firstName, e.lastName, q.degree AS qualification, p.position " +
                                 "FROM employee e " +
                                 "LEFT JOIN qualification q ON e.empId = q.empId " +
                                 "LEFT JOIN position p ON e.empId = p.empId");
    rs = pstmt.executeQuery();
} catch (Exception e) {
    e.printStackTrace();
}

// Format current date and time
SimpleDateFormat sdf = new SimpleDateFormat("EEE MMM dd HH:mm:ss z yyyy");
String currentDate = sdf.format(new Date());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HR Panel</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/hr_style.css">
</head>
<body>

<!-- HR Header (Matching Admin Dashboard) -->
<header class="hr-header">
    <div class="header-content">
        <div class="logo-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-unity logo-icon" viewBox="0 0 16 16">
                <path d="M15 11.2V3.733L8.61 0v2.867l2.503 1.466c.099.067.099.2 0 .234L8.148 6.3c-.099.067-.197.033-.263 0L4.92 4.567c-.099-.034-.099-.2 0-.234l2.504-1.466V0L1 3.733V11.2v-.033.033l2.438-1.433V6.833c0-.1.131-.166.197-.133L6.6 8.433c.099.067.132.134.132.234v3.466c0 .1-.132.167-.198.134L4.031 10.8l-2.438 1.433L7.983 16l6.391-3.733-2.438-1.434L9.434 12.3c-.099.067-.198 0-.198-.133V8.7c0-.1.066-.2.132-.233l2.965-1.734c.099-.066.197 0 .197.134V9.8z"/>
            </svg>
            <span class="logo-text">PathForge</span>
        </div>
        <div class="hr-profile">
            <img src="<%= profileImageBase64 != null ? "data:image/jpeg;base64," + profileImageBase64 : "assets/images/profile2.jpg" %>" alt="HR Profile" class="profile-image">
            <div class="hr-details">
                <span class="hr-name"><%= hrName %></span>
                <span class="hr-email"><%= hrEmail %></span>
                <span class="hr-role">(HR)</span>
                <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- Welcome Pop-Up -->
<div id="welcomePopup" class="popup">
    <div class="popup-content">
        <span class="close-btn" onclick="closePopup()">×</span>
        <h2>Welcome, <%= hrName %>!</h2>
        <p>We're glad to have you back. Manage and view employee records with ease.</p>
        <button onclick="closePopup()" class="popup-close-btn">Got It!</button>
    </div>
</div>

<!-- HR Main Content -->
<main class="content">
    <!-- Welcome Section (Matching Admin Dashboard) -->
    <div class="welcome-section">
        <h1 class="content-title">Welcome, <%= hrName %></h1>
        <p class="content-subtitle">Modify active users, view reports, and configure settings.</p>
    </div>
    <div class="date-export-section">
        <span class="current-date"><%= currentDate %></span>
        <div class="export-options">
            <select class="time-range">
                <option value="this-month">This month</option>
                <option value="last-month">Last month</option>
                <option value="this-year">This year</option>
            </select>
            <a href="viewReports.jsp" class="export-btn"><i class="fas fa-chart-line"></i> View Report</a>
        </div>
    </div>

    <!-- Original HR Content -->
    <p class="manage-text">Manage employee records below:</p>

    <% if (!message.isEmpty()) { %>
        <p class="message <%= message.contains("Error") ? "error" : "success" %>"><%= message %></p>
    <% } %>

    <!-- Employee Table -->
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Emp ID</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Qualification</th>
                    <th>Position</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                if (!rs.isBeforeFirst()) {
                %>
                <tr>
                    <td colspan="6" class="no-data">No employees found.</td>
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
                    <td>
                        <a href="edit_employee.jsp?id=<%= rs.getString("empId") %>" class="action-link edit">Edit</a>
                        <a href="hr.jsp?delete=<%= rs.getString("empId") %>" class="action-link delete" onclick="return confirm('Are you sure you want to delete this employee?')">Delete</a>
                    </td>
                </tr>
                <%
                    }
                }
                %>
            </tbody>
        </table>
    </div>

    <!-- Add Employee Form -->
    <h2 class="section-title">Add Employee</h2>
    <form action="add_employee.jsp" method="POST" class="add-employee-form">
        <div class="form-group">
            <label for="empId">Employee ID</label>
            <div class="input-wrapper">
                <input type="text" id="empId" name="empId" placeholder="Enter Employee ID" required>
            </div>
        </div>
        <div class="form-group">
            <label for="firstname">First Name</label>
            <div class="input-wrapper">
                <input type="text" id="firstname" name="firstname" placeholder="Enter First Name" required>
            </div>
        </div>
        <div class="form-group">
            <label for="lastname">Last Name</label>
            <div class="input-wrapper">
                <input type="text" id="lastname" name="lastname" placeholder="Enter Last Name" required>
            </div>
        </div>
        <div class="form-group">
            <label for="qualification">Qualification</label>
            <div class="input-wrapper">
                <select id="qualification" name="qualification" required>
                    <option value="" disabled selected>Select Qualification</option>
                    <option value="Certificate">Certificate</option>
                    <option value="Diploma">Diploma</option>
                    <option value="Bachelor">Bachelor</option>
                    <option value="Masters">Masters</option>
                    <option value="PhD">PhD</option>
                </select>
            </div>
        </div>
        <div class="form-group">
            <label for="position">Position</label>
            <div class="input-wrapper">
                <select id="position" name="position" required>
                    <option value="" disabled selected>Select Position</option>
                    <option value="Manager">Manager</option>
                    <option value="Staff">Staff</option>
                    <option value="Finance">Finance</option>
                </select>
            </div>
        </div>
        <button type="submit" class="submit-btn">Add Employee</button>
    </form>
</main>

<!-- Footer (Matching Admin Dashboard) -->
<footer class="hr-footer">
    <p>© 2025 PathForge. All rights reserved.</p>
</footer>

<!-- JavaScript for Pop-Up -->
<script>
    // Function to get cookie value by name
    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }

    // Function to show the pop-up
    function showPopup() {
        document.getElementById('welcomePopup').style.display = 'flex';
    }

    // Function to close the pop-up
    function closePopup() {
        document.getElementById('welcomePopup').style.display = 'none';
        // Optionally, set the cookie again to ensure it persists
        document.cookie = "welcomePopupShown=true; path=/; max-age=" + (30 * 24 * 60 * 60);
    }

    // Check if the welcome pop-up cookie exists
    window.onload = function() {
        const popupShown = getCookie('welcomePopupShown');
        if (!popupShown || popupShown !== 'true') {
            showPopup();
        }
    };
</script>

<%
if (rs != null) rs.close();
if (pstmt != null) pstmt.close();
if (conn != null) conn.close();
%>
</body>
</html>