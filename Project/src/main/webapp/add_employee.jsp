<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Employee</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="assets/css/add_employee_style.css">
</head>
<body>
    <div class="form-container">
        <div class="form-card">
            <h1 class="form-title">Add New Employee</h1>
            <form action="addEmployee.jsp" method="post" class="employee-form">
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
                            <option value="Masters">Masters</option>
                            <option value="Diploma">Diploma</option>
                            <option value="Bachelor">Bachelor</option>
                            <option value="PhD">PhD</option>
                            <option value="Professor">Professor</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label for="position">Position</label>
                    <div class="input-wrapper">
                        <select id="position" name="position" required>
                            <option value="" disabled selected>Select Position</option>
                            <option value="Manager">Manager</option>
                            <option value="Employee">Employee</option>
                            <option value="Director">Director</option>
                            <option value="Keeper">Keeper</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="submit-btn">Add Employee</button>
            </form>
            <p class="back-link"><a href="hr.jsp">Back to HR Dashboard</a></p>

            <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String empId = request.getParameter("empId");
                String firstName = request.getParameter("firstname");
                String lastName = request.getParameter("lastname");
                String qualification = request.getParameter("qualification");
                String position = request.getParameter("position");

                Connection conn = null;
                PreparedStatement pstmtEmployee = null;
                PreparedStatement pstmtQualification = null;
                PreparedStatement pstmtPosition = null;
                PreparedStatement pstmtCheck = null;
                ResultSet rs = null;

                try {
                    // Validate input fields
                    if (empId == null || firstName == null || lastName == null || qualification == null || position == null ||
                        empId.trim().isEmpty() || firstName.trim().isEmpty() || lastName.trim().isEmpty() ||
                        qualification.trim().isEmpty() || position.trim().isEmpty()) {
                        out.println("<p class='message error'>All fields are required!</p>");
                    } else {
                        conn = DBConnection.getConnection();
                        if (conn == null) {
                            out.println("<p class='message error'>Database connection failed!</p>");
                        } else {
                            // Start a transaction
                            conn.setAutoCommit(false);

                            // Check if empId already exists
                            pstmtCheck = conn.prepareStatement("SELECT COUNT(*) FROM employee WHERE empId = ?");
                            pstmtCheck.setString(1, empId);
                            rs = pstmtCheck.executeQuery();
                            rs.next();
                            if (rs.getInt(1) > 0) {
                                out.println("<p class='message error'>Employee ID already exists!</p>");
                                conn.rollback();
                            } else {
                                // Insert into employee table
                                pstmtEmployee = conn.prepareStatement("INSERT INTO employee (empId, firstName, lastName) VALUES (?, ?, ?)");
                                pstmtEmployee.setString(1, empId);
                                pstmtEmployee.setString(2, firstName);
                                pstmtEmployee.setString(3, lastName);
                                int employeeRows = pstmtEmployee.executeUpdate();

                                // Insert into qualification table
                                pstmtQualification = conn.prepareStatement("INSERT INTO qualification (empId, degree) VALUES (?, ?)");
                                pstmtQualification.setString(1, empId);
                                pstmtQualification.setString(2, qualification);
                                int qualRows = pstmtQualification.executeUpdate();

                                // Insert into position table
                                pstmtPosition = conn.prepareStatement("INSERT INTO position (empId, position) VALUES (?, ?)");
                                pstmtPosition.setString(1, empId);
                                pstmtPosition.setString(2, position);
                                int posRows = pstmtPosition.executeUpdate();

                                if (employeeRows > 0 && qualRows > 0 && posRows > 0) {
                                    conn.commit();
                                    response.sendRedirect("hr.jsp?message=Employee Added Successfully");
                                } else {
                                    conn.rollback();
                                    out.println("<p class='message error'>Failed to add employee.</p>");
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (SQLException ignored) {}
                    }
                    e.printStackTrace();
                    out.println("<p class='message error'>Error: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                    if (pstmtCheck != null) try { pstmtCheck.close(); } catch (SQLException ignored) {}
                    if (pstmtEmployee != null) try { pstmtEmployee.close(); } catch (SQLException ignored) {}
                    if (pstmtQualification != null) try { pstmtQualification.close(); } catch (SQLException ignored) {}
                    if (pstmtPosition != null) try { pstmtPosition.close(); } catch (SQLException ignored) {}
                    if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
                }
            }
            %>
        </div>
    </div>
</body>
</html>