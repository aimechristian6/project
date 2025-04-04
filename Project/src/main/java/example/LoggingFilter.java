package example;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

public class LoggingFilter implements Filter {
    @Override
    public void init(FilterConfig config) throws ServletException {
        // Initialization logic
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        System.out.println("Request to " + request.getRequestURI() + " from IP: " + request.getRemoteAddr());
        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {
        // Cleanup logic
    }
}