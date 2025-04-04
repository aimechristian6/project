<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="java.io.*, jakarta.servlet.http.Part" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/styles2.css">
</head>
<body>
    <div class="signup-container">
        <div class="signup-card">
            <div class="logo-section">
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="currentColor" class="bi bi-unity logo-icon" viewBox="0 0 16 16">
                    <path d="M15 11.2V3.733L8.61 0v2.867l2.503 1.466c.099.067.099.2 0 .234L8.148 6.3c-.099.067-.197.033-.263 0L4.92 4.567c-.099-.034-.099-.2 0-.234l2.504-1.466V0L1 3.733V11.2v-.033.033l2.438-1.433V6.833c0-.1.131-.166.197-.133L6.6 8.433c.099.067.132.134.132.234v3.466c0 .1-.132.167-.198.134L4.031 10.8l-2.438 1.433L7.983 16l6.391-3.733-2.438-1.434L9.434 12.3c-.099.067-.198 0-.198-.133V8.7c0-.1.066-.2.132-.233l2.965-1.734c.099-.066.197 0 .197.134V9.8z"/>
                </svg>
                <span class="logo-text">PathForge</span>
            </div>
            <h1 class="signup-title">Sign Up</h1>
            <form action="register.jsp" method="post" enctype="multipart/form-data" class="signup-form">
                <div class="form-group">
                    <label for="name"><i class="fas fa-user"></i> Full Name</label>
                    <div class="input-wrapper">
                        <input type="text" id="name" name="name" placeholder="Enter your full name" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="email"><i class="fas fa-envelope"></i> Email</label>
                    <div class="input-wrapper">
                        <input type="email" id="email" name="email" placeholder="Enter your email" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="dob"><i class="fas fa-calendar-alt"></i> Date of Birth</label>
                    <div class="input-wrapper">
                        <input type="date" id="dob" name="dob" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="role"><i class="fas fa-briefcase"></i> Role</label>
                    <div class="input-wrapper">
                        <select id="role" name="role" required>
                            <option value="" disabled selected>Select Role</option>
                            <option value="admin">Admin</option>
                            <option value="hr">HR</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label for="password"><i class="fas fa-lock"></i> Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="profileImage"><i class="fas fa-image"></i> Profile Image</label>
                    <div class="input-wrapper">
                        <input type="file" id="profileImage" name="profileImage" accept="image/*" required>
                    </div>
                </div>
                <div class="form-group checkbox-group">
                    <label>
                        <input type="checkbox" name="subscribed" required> Agree Terms And Conditions
                    </label>
                </div>
                <button type="submit" class="signup-btn">Register <i class="fas fa-user-plus"></i></button>
            </form>
            <p class="login-link">Already have an account? <a href="login.jsp">Login</a></p>
            <%-- Display any error or success messages --%>
            <% if (request.getAttribute("message") != null) { %>
                <p class="message <%= request.getAttribute("messageColor").equals("red") ? "error" : "success" %>">
                    <%= request.getAttribute("message") %>
                </p>
            <% } %>
        </div>
    </div>

    <%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String dobString = request.getParameter("dob");
        String role = request.getParameter("role");
        String password = request.getParameter("password");
        boolean subscribed = request.getParameter("subscribed") != null;
        Part filePart = null;
        byte[] imageBytes = null;

        // File handling with detailed logging
        try {
            filePart = request.getPart("profileImage");
            System.out.println("FilePart retrieved: " + (filePart != null ? "Yes" : "No"));
            System.out.println("FilePart size: " + (filePart != null ? filePart.getSize() : "N/A") + " bytes");
            if (filePart == null || filePart.getSize() <= 0) {
                request.setAttribute("message", "Please upload a profile image or file size is 0.");
                request.setAttribute("messageColor", "red");
                return;
            }

            try (InputStream inputStream = filePart.getInputStream()) {
                System.out.println("InputStream opened successfully.");
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
                imageBytes = outputStream.toByteArray();
                System.out.println("Image bytes length: " + imageBytes.length);
                if (imageBytes.length > 5 * 1024 * 1024) {
                    request.setAttribute("message", "Image size must be less than 5MB.");
                    request.setAttribute("messageColor", "red");
                    return;
                }
            }
        } catch (IOException e) {
            request.setAttribute("message", "Error reading image: " + e.getMessage());
            request.setAttribute("messageColor", "red");
            System.err.println("IOException in image processing: " + e.getMessage());
            e.printStackTrace();
            return;
        } catch (Exception e) {
            request.setAttribute("message", "Unexpected error processing image: " + e.getMessage());
            request.setAttribute("messageColor", "red");
            System.err.println("Unexpected exception: " + e.getMessage());
            e.printStackTrace();
            return;
        }

        // Database insertion with detailed logging
        Connection conn = null;
        try {
            java.sql.Date dob = java.sql.Date.valueOf(dobString);

            conn = DBConnection.getConnection();
            System.out.println("Database connection successful.");
            String sql = "INSERT INTO users (name, email, dob, role, password, subscribed, status, profile_image) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, name);
                stmt.setString(2, email);
                stmt.setDate(3, dob);
                stmt.setString(4, role);
                stmt.setString(5, password);
                stmt.setBoolean(6, subscribed);
                stmt.setString(7, "inactive");
                stmt.setBytes(8, imageBytes);
                System.out.println("Executing INSERT with image bytes length: " + (imageBytes != null ? imageBytes.length : "null"));
                int rowsAffected = stmt.executeUpdate();
                System.out.println("Rows affected: " + rowsAffected);
                if (rowsAffected > 0) {
                    request.setAttribute("message", "Registration successful! Redirecting to login...");
                    request.setAttribute("messageColor", "green");
                    response.setHeader("Refresh", "2;url=login.jsp");
                } else {
                    request.setAttribute("message", "Failed to insert user data.");
                    request.setAttribute("messageColor", "red");
                }
            }
        } catch (SQLException e) {
            request.setAttribute("message", "Database error: " + e.getMessage());
            request.setAttribute("messageColor", "red");
            System.err.println("SQLException: " + e.getMessage());
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            request.setAttribute("message", "Invalid date format: " + e.getMessage());
            request.setAttribute("messageColor", "red");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    System.out.println("Database connection closed.");
                } catch (SQLException e) {
                    System.err.println("Error closing connection: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }
    %>
</body>
</html>