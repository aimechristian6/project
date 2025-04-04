<%@ page import="java.sql.*, example.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
if (session != null && session.getAttribute("user") != null) {
    String email = (String) session.getAttribute("user");

    try (Connection conn = DBConnection.getConnection()) {
        String sql = "UPDATE users SET status = 'inactive' WHERE email = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.executeUpdate();
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    session.invalidate(); // This triggers sessionDestroyed in SessionListener
}

response.sendRedirect("login.jsp");
%>