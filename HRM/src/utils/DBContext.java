package utils;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {

    protected Connection connection;

    public DBContext() {

        try {

            String url = "jdbc:sqlserver://localhost:1433;"
                    + "databaseName=HRM_System;"
                    + "encrypt=true;"
                    + "trustServerCertificate=true";

            String user = "sa";
            String password = "123456";

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            connection = DriverManager.getConnection(url, user, password);

            System.out.println("Connect success!");

        } catch (Exception e) {

            e.printStackTrace();
        }
    }
}
