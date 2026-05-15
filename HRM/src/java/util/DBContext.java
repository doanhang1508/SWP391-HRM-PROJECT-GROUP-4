/*
 * Utility class for managing database connections to SQL Server.
 * Uses JDBC to connect to the HRM_System database.
 */
package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBContext - Provides database connection for the HRM System.
 * Connects to SQL Server using JDBC.
 */
public class DBContext {

    /**
     * Database connection parameters.
     * Adjust these values according to your SQL Server configuration.
     */
    private static final String SERVER_NAME = "localhost";
    private static final String DB_NAME = "HRM_System";
    private static final String PORT = "1433";
    private static final String USER = "sa";
    private static final String PASSWORD = "123"; // Change to your SQL Server password

    /**
     * Gets a connection to the SQL Server database.
     *
     * @return Connection object to the HRM_System database
     * @throws SQLException if a database access error occurs
     * @throws ClassNotFoundException if the JDBC driver class is not found
     */
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT
                + ";databaseName=" + DB_NAME
                + ";encrypt=true;trustServerCertificate=true";
        return DriverManager.getConnection(url, USER, PASSWORD);
    }
}
