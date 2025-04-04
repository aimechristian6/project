package example;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/viewReports")
public class ViewReportServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ViewReportServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            LOGGER.warning("Unauthorized access to View Reports");
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        List<Map<String, Object>> reportData = getLoginReport();
        LOGGER.info("Fetched " + reportData.size() + " login records for HR and Admin");

        request.setAttribute("reportData", reportData);
        request.getRequestDispatcher("viewReports.jsp").forward(request, response);
    }

    private List<Map<String, Object>> getLoginReport() {
        List<Map<String, Object>> reportData = new ArrayList<>();
        String sql = "SELECT u.username, u.role, u.profile_picture, s.login_time " +
                "FROM users u " +
                "JOIN sessions s ON u.user_id = s.user_id " +
                "WHERE u.role IN ('Admin', 'HR') " +
                "ORDER BY s.login_time DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("username", rs.getString("username"));
                record.put("role", rs.getString("role"));
                record.put("loginTime", rs.getTimestamp("login_time"));
                String profilePicture = rs.getString("profile_picture");
                record.put("profilePicture", profilePicture != null ? profilePicture : "/images/default_profile.jpg");
                reportData.add(record);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching login report: " + e.getMessage());
        }
        return reportData;
    }
}
