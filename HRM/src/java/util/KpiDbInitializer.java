package util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Properties;

public class KpiDbInitializer {
    public static void main(String[] args) {
        String dbServer = "localhost";
        String dbPort = "3306";
        String dbName = "hrm_system";
        String dbUser = "root";
        String dbPassword = "123456";

        // Try to load properties
        try (InputStream is = KpiDbInitializer.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                dbServer = props.getProperty("db.server", dbServer);
                dbPort = props.getProperty("db.port", dbPort);
                dbName = props.getProperty("db.name", dbName);
                dbUser = props.getProperty("db.user", dbUser);
                dbPassword = props.getProperty("db.password", dbPassword);
            }
        } catch (Exception e) {
            System.err.println("Warning: Could not load db.properties: " + e.getMessage());
        }

        String url = "jdbc:mysql://" + dbServer + ":" + dbPort + "/" + dbName + "?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Ho_Chi_Minh";

        System.out.println("Connecting to: " + url + " as " + dbUser);

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            System.err.println("JDBC Driver not found!");
            e.printStackTrace();
            return;
        }

        // Read SQL file
        StringBuilder sqlBuilder = new StringBuilder();
        String sqlFilePath = "../database/kpi_evaluation_setup.sql"; // Relative path from HRM folder, or just use absolute path.
        // Let's try multiple potential paths to be robust
        String[] potentialPaths = {
            "database/kpi_evaluation_setup.sql",
            "../database/kpi_evaluation_setup.sql",
            "./database/kpi_evaluation_setup.sql",
            "c:/Users/nguye/OneDrive/Documents/SUMMER26/1_SWP391/SWP391-HRM-PROJECT-GROUP-4/database/kpi_evaluation_setup.sql"
        };

        boolean fileLoaded = false;
        for (String path : potentialPaths) {
            try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    // Skip comment lines in SQL
                    if (line.trim().startsWith("--") || line.trim().startsWith("#")) {
                        continue;
                    }
                    sqlBuilder.append(line).append("\n");
                }
                fileLoaded = true;
                System.out.println("Successfully read SQL file from: " + path);
                break;
            } catch (Exception ignored) {
            }
        }

        if (!fileLoaded) {
            System.err.println("Error: Could not locate kpi_evaluation_setup.sql in any expected path!");
            return;
        }

        String fullSql = sqlBuilder.toString();

        try (Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
             Statement stmt = conn.createStatement()) {
            System.out.println("Connection established. Running database migration...");
            
            // We can run the whole SQL script using allowMultiQueries=true
            stmt.execute(fullSql);
            System.out.println("Database migration completed successfully!");
        } catch (Exception e) {
            System.err.println("Migration failed!");
            e.printStackTrace();
        }
    }
}
