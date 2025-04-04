<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Employee</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="assets/css/edit_employee_style.css">
</head>
<body>
    <%
    String empId = request.getParameter("empId");
    String firstName = request.getParameter("firstname");
    String lastName = request.getParameter("lastname");
    String qualification = request.getParameter("qualification");
    String position = request.getParameter("position");

    Connection conn = null;
    PreparedStatement pstmtEmployee = null;
    PreparedStatement pstmtQualification = null;
    PreparedStatement pstmtPosition = null;

    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        // Update employee table
        pstmtEmployee = conn.prepareStatement("UPDATE employee SET firstName = ?, lastName = ? WHERE empId = ?");
        pstmtEmployee.setString(1, firstName);
        pstmtEmployee.setString(2, lastName);
        pstmtEmployee.setString(3, empId);
        int employeeRows = pstmtEmployee.executeUpdate();

        // Update qualification table (delete existing and insert new)
        pstmtQualification = conn.prepareStatement("DELETE FROM qualification WHERE empId = ?");
        pstmtQualification.setString(1, empId);
        pstmtQualification.executeUpdate();
        pstmtQualification = conn.prepareStatement("INSERT INTO qualification (empId, degree) VALUES (?, ?)");
        pstmtQualification.setString(1, empId);
        pstmtQualification.setString(2, qualification);
        int qualRows = pstmtQualification.executeUpdate();

        // Update position table (delete existing and insert new)
        pstmtPosition = conn.prepareStatement("DELETE FROM position WHERE empId = ?");
        pstmtPosition.setString(1, empId);
        pstmtPosition.executeUpdate();
        pstmtPosition = conn.prepareStatement("INSERT INTO position (empId, position) VALUES (?, ?)");
        pstmtPosition.setString(1, empId);
        pstmtPosition.setString(2, position);
        int posRows = pstmtPosition.executeUpdate();

        if (employeeRows > 0 && qualRows > 0 && posRows > 0) {
            conn.commit();
            response.sendRedirect("hr.jsp?message=Employee Updated Successfully");
        } else {
            conn.rollback();
            response.sendRedirect("hr.jsp?message=Error updating employee.");
        }
    } catch (Exception e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {}
        }
        e.printStackTrace();
        response.sendRedirect("hr.jsp?message=Error: " + e.getMessage());
    } finally {
        if (pstmtEmployee != null) pstmtEmployee.close();
        if (pstmtQualification != null) pstmtQualification.close();
        if (pstmtPosition != null) pstmtPosition.close();
        if (conn != null) {
            conn.setAutoCommit(true);
            conn.close();
        }
    }
    %>
</body>
</html>