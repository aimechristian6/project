<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/admin_style.css">
</head>
<body>

<%
if (session == null || session.getAttribute("user") == null || !"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}

String adminEmail = (String) session.getAttribute("user");
byte[] adminImage = null;
String adminName = "";

try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT name, profile_image FROM users WHERE email = ?";
    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, adminEmail);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            adminName = rs.getString("name");
            adminImage = rs.getBytes("profile_image");
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
    adminImage = null;
}

// Format current date and time
SimpleDateFormat sdf = new SimpleDateFormat("EEE MMM dd HH:mm:ss z yyyy");
String currentDate = sdf.format(new Date());
%>

<!-- Admin Header -->
<header class="admin-header">
    <div class="header-content">
        <div class="logo-section">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-unity logo-icon" viewBox="0 0 16 16">
                <path d="M15 11.2V3.733L8.61 0v2.867l2.503 1.466c.099.067.099.2 0 .234L8.148 6.3c-.099.067-.197.033-.263 0L4.92 4.567c-.099-.034-.099-.2 0-.234l2.504-1.466V0L1 3.733V11.2v-.033.033l2.438-1.433V6.833c0-.1.131-.166.197-.133L6.6 8.433c.099.067.132.134.132.234v3.466c0 .1-.132.167-.198.134L4.031 10.8l-2.438 1.433L7.983 16l6.391-3.733-2.438-1.434L9.434 12.3c-.099.067-.198 0-.198-.133V8.7c0-.1.066-.2.132-.233l2.965-1.734c.099-.066.197 0 .197.134V9.8z"/>
            </svg>
            <span class="logo-text">PathForge</span>
        </div>
        <div class="admin-profile">
            <img src="<%= adminImage != null ? "data:image/jpeg;base64," + Base64.getEncoder().encodeToString(adminImage) : "assets/images/profile.jpg" %>" alt="Admin Profile" class="profile-image">
            <div class="admin-details">
                <span class="admin-name"><%= adminName %></span>
                <span class="admin-email"><%= adminEmail %></span>
                <span class="admin-role">(Admin)</span>
                <a href="logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- Welcome Pop-Up -->
<div id="welcomePopup" class="popup">
    <div class="popup-content">
        <span class="close-btn" onclick="closePopup()">×</span>
        <h2>Welcome, <%= adminName %>!</h2>
        <p>We're glad to have you back. Explore the dashboard to manage users and settings.</p>
        <button onclick="closePopup()" class="popup-close-btn">Got It!</button>
    </div>
</div>

<!-- Page Content -->
<main class="content">
    <div class="welcome-section">
        <h1 class="content-title">Welcome, <%= adminName %></h1>
        <p class="content-subtitle">Monitor active users, view reports, and configure settings.</p>
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
    <div class="active-admins-section">
        <h2 class="section-title">Active Admins <span class="admin-count">
            <%= application.getAttribute("activeAdminSessions") != null ? application.getAttribute("activeAdminSessions") : 0 %>
        </span></h2>
    </div>
    <div class="active-users-section">
        <h2 class="section-title">Active Users</h2>
        <table class="users-table">
            <thead>
                <tr>
                    <th>User Name</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT name FROM users WHERE status = 'active'";
                        try (PreparedStatement stmt = conn.prepareStatement(sql);
                             ResultSet rs = stmt.executeQuery()) {
                            while (rs.next()) {
                                out.print("<tr><td>" + rs.getString("name") + "</td></tr>");
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                        out.print("<tr><td class='error'>Database error</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</main>

<!-- Footer -->
<footer class="admin-footer">
    <p>&copy; <span id="currentYear"></span> PathForge. All rights reserved.</p>
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
        const popup = document.getElementById('welcomePopup');
        if (popup) {
            popup.style.display = 'flex';
        } else {
            console.error("Popup element not found!");
        }
    }

    // Function to close the pop-up
    function closePopup() {
        console.log("closePopup() called");
        const popup = document.getElementById('welcomePopup');
        if (popup) {
            popup.style.display = 'none';
            document.cookie = "welcomePopupShown=true; path=/; max-age=" + (30 * 24 * 60 * 60);
        } else {
            console.error("Popup element not found!");
        }
    }
    // Check if the welcome pop-up cookie exists
    window.onload = function() {
        const popupShown = getCookie('welcomePopupShown');
        if (!popupShown || popupShown !== 'true') {
            showPopup();
        }
    };
</script>

</body>
</html>