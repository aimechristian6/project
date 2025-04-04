<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Employee</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="assets/css/edit_employee_style.css">
</head>
<body>
    <div class="form-container">
        <div class="form-card">
            <h1 class="form-title">Edit Employee</h1>
            <%
            String empIdParam = request.getParameter("id"); // Use String to avoid NumberFormatException
            if (empIdParam == null) {
                out.println("<p class='message error'>Employee ID is missing.</p>");
            } else {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;

                try {
                    conn = DBConnection.getConnection();
                    pstmt = conn.prepareStatement("SELECT e.empId, e.firstName, e.lastName, q.degree AS qualification, p.position " +
                                                 "FROM employee e " +
                                                 "LEFT JOIN qualification q ON e.empId = q.empId " +
                                                 "LEFT JOIN position p ON e.empId = p.empId " +
                                                 "WHERE e.empId = ?");
                    pstmt.setString(1, empIdParam);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
            %>
            <form action="update_employee.jsp" method="POST" class="edit-employee-form">
                <div class="form-group">
                    <label for="empId"><i class="fas fa-id-card"></i> Employee ID</label>
                    <div class="input-wrapper">
                        <input type="text" id="empId" name="empId" value="<%= rs.getString("empId") %>" readonly required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="firstname"><i class="fas fa-user"></i> First Name</label>
                    <div class="input-wrapper">
                        <input type="text" id="firstname" name="firstname" value="<%= rs.getString("firstName") %>" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="lastname"><i class="fas fa-user"></i> Last Name</label>
                    <div class="input-wrapper">
                        <input type="text" id="lastname" name="lastname" value="<%= rs.getString("lastName") %>" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="qualification"><i class="fas fa-graduation-cap"></i> Qualification</label>
                    <div class="input-wrapper">
                        <select id="qualification" name="qualification" required>
                            <option value="" disabled <%= rs.getString("qualification") == null ? "selected" : "" %>>Select Qualification</option>
                            <option value="Masters" <%= "Masters".equals(rs.getString("qualification")) ? "selected" : "" %>>Masters</option>
                            <option value="Diploma" <%= "Diploma".equals(rs.getString("qualification")) ? "selected" : "" %>>Diploma</option>
                            <option value="Bachelor" <%= "Bachelor".equals(rs.getString("qualification")) ? "selected" : "" %>>Bachelor</option>
                            <option value="PhD" <%= "PhD".equals(rs.getString("qualification")) ? "selected" : "" %>>PhD</option>
                            <option value="Professor" <%= "Professor".equals(rs.getString("qualification")) ? "selected" : "" %>>Professor</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label for="position"><i class="fas fa-briefcase"></i> Position</label>
                    <div class="input-wrapper">
                        <select id="position" name="position" required>
                            <option value="" disabled <%= rs.getString("position") == null ? "selected" : "" %>>Select Position</option>
                            <option value="Manager" <%= "Manager".equals(rs.getString("position")) ? "selected" : "" %>>Manager</option>
                            <option value="Employee" <%= "Employee".equals(rs.getString("position")) ? "selected" : "" %>>Employee</option>
                            <option value="Director" <%= "Director".equals(rs.getString("position")) ? "selected" : "" %>>Director</option>
                            <option value="Keeper" <%= "Keeper".equals(rs.getString("position")) ? "selected" : "" %>>Keeper</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="submit-btn">Update Employee <i class="fas fa-save"></i></button>
            </form>
            <p class="back-link"><a href="hr.jsp">Back to HR Dashboard</a></p>
            <%
                    } else {
                        out.println("<p class='message error'>Employee not found.</p>");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p class='message error'>Error: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            }
            %>
        </div>
    </div>
</body>
</html>