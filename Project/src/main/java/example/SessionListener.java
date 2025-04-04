package example;

import jakarta.servlet.ServletContext;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;

@WebListener
public class SessionListener implements HttpSessionListener {

    private static int activeAdminSessions = 0;

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // No action needed on session creation; handled in login.jsp
        System.out.println("Session created.");
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // Decrement only if the session was an admin session
        String role = (String) se.getSession().getAttribute("role");
        if ("admin".equals(role)) {
            activeAdminSessions--;
            if (activeAdminSessions < 0) activeAdminSessions = 0; // Prevent negative counts
            ServletContext context = se.getSession().getServletContext();
            context.setAttribute("activeAdminSessions", activeAdminSessions);
            System.out.println("Admin session destroyed. Total active admin sessions: " + activeAdminSessions);
        }
    }

    public static int getActiveAdminSessions() {
        return activeAdminSessions;}
    }

