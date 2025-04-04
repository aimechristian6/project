package example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:postgresql://localhost:5432/employeedb";
    private static final String USER = "postgres"; // Replace with your DB username
    private static final String PASSWORD = "kigali2025"; // Replace with your DB password

    static {
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("PostgreSQL Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("Failed to register PostgreSQL Driver: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Database connection established successfully.");
            return conn;
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
            throw e; // Re-throw to be handled by the caller
        }
    }
}