<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/styles3.css">
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="logo-section">
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-unity logo-icon" viewBox="0 0 16 16">
                    <path d="M15 11.2V3.733L8.61 0v2.867l2.503 1.466c.099.067.099.2 0 .234L8.148 6.3c-.099.067-.197.033-.263 0L4.92 4.567c-.099-.034-.099-.2 0-.234l2.504-1.466V0L1 3.733V11.2v-.033.033l2.438-1.433V6.833c0-.1.131-.166.197-.133L6.6 8.433c.099.067.132.134.132.234v3.466c0 .1-.132.167-.198.134L4.031 10.8l-2.438 1.433L7.983 16l6.391-3.733-2.438-1.434L9.434 12.3c-.099.067-.198 0-.198-.133V8.7c0-.1.066-.2.132-.233l2.965-1.734c.099-.066.197 0 .197.134V9.8z"/>
                </svg>
                <span class="logo-text">PathForge</span>
            </div>
            <h1 class="login-title">Sign In</h1>
            <form action="login.jsp" method="post" class="login-form">
                <div class="form-group">
                    <label for="email"><i class="fas fa-envelope"></i> Email</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" placeholder="Enter your email" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="password"><i class="fas fa-lock"></i> Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                    </div>
                </div>
                <button type="submit" class="login-btn">Sign In <i class="fas fa-sign-in-alt"></i></button>
            </form>
            <p class="signup-link">Don't have an account? <a href="register.jsp">Sign Up</a></p>
            <%
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String email = request.getParameter("email");
                    String password = request.getParameter("password");

                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT role FROM users WHERE email = ? AND password = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                            stmt.setString(1, email);
                            stmt.setString(2, password);
                            ResultSet rs = stmt.executeQuery();

                            if (rs.next()) {
                                String role = rs.getString("role");
                                session.setAttribute("user", email);
                                session.setAttribute("role", role);

                                String updateSql = "UPDATE users SET status = 'active' WHERE email = ?";
                                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                                    updateStmt.setString(1, email);
                                    updateStmt.executeUpdate();
                                }

                                // Increment active admin sessions if role is admin
                                if ("admin".equals(role)) {
                                    Integer activeAdminSessions = (Integer) application.getAttribute("activeAdminSessions");
                                    if (activeAdminSessions == null) activeAdminSessions = 0;
                                    activeAdminSessions++;
                                    application.setAttribute("activeAdminSessions", activeAdminSessions);
                                    System.out.println("Admin logged in. Total active admin sessions: " + activeAdminSessions);
                                }

                                // Set a cookie to track if the welcome pop-up has been shown
                                Cookie welcomePopupCookie = new Cookie("welcomePopupShown", "true");
                                welcomePopupCookie.setMaxAge(30 * 24 * 60 * 60); // Cookie expires in 30 days
                                welcomePopupCookie.setPath("/"); // Cookie is available across the entire app
                                response.addCookie(welcomePopupCookie);

                                if ("admin".equals(role)) {
                                    response.sendRedirect("admin.jsp");
                                } else if ("hr".equals(role)) {
                                    response.sendRedirect("hr.jsp");
                                } else {
                                    response.sendRedirect("home.jsp");
                                }
                            } else {
                                out.println("<p class='message error'>Invalid email or password.</p>");
                            }
                        }
                    } catch (Exception e) {
                        out.println("<p class='message error'>Database error: " + e.getMessage() + "</p>");
                    }
                }
            %>
        </div>
    </div>
</body>
</html>