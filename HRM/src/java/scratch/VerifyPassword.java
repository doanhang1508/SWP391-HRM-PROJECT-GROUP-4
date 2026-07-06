import org.mindrot.jbcrypt.BCrypt;

public class VerifyPassword {
    public static void main(String[] args) {
        String[] hashes = {
            "$2a$12$rYoA1kECJ6UezPnfPqISP.Gg1Goc4FUiqLGQIFBOHqFbiBis2C4.i", // admin
            "$2a$12$VmGdTMHeOmArIfaKnIm7KuR4IeZScPaJatyvb8aq6bQDqDUvU0FWe", // giam_doc
            "$2a$12$KlvlpagR4obNSuv2XfM32uWEVqKfNFT5t5JUzRMCrYGi.1QetPgEy", // hr_manager
            "$2a$12$Pz91uQpiTf8GgwrkbiA/ReDRjxRk48K4lu2Y5yxLGlxQQutJ2xUIm", // quan_doc
            "$2a$12$9rsQL.viVSSU3uxAqO4aI.LVVYSyc6i1BaZSvrF5SPnAKijaaMmFK"  // cong_nhan
        };
        String[] usernames = {"admin", "giam_doc", "hr_manager", "quan_doc", "cong_nhan"};

        String[] dictionary = {
            "123", "1234", "12345", "123456", "12345678", "123456789", "admin", "admin123", "admin@123", "Admin123", "Admin@123", "password", "1234567",
            "cong_nhan", "congnhan", "quan_doc", "quandoc", "giam_doc", "giamdoc", "hr_manager", "hrmanager",
            "hrm", "hrm123", "hrm@123", "Hrm123", "Hrm@123"
        };

        for (int i = 0; i < hashes.length; i++) {
            String hash = hashes[i];
            String username = usernames[i];
            boolean found = false;
            for (String pass : dictionary) {
                if (BCrypt.checkpw(pass, hash)) {
                    System.out.printf("FOUND! User: %s -> Password: %s\n", username, pass);
                    found = true;
                    break;
                }
            }
            if (!found) {
                System.out.printf("Not found for user: %s\n", username);
            }
        }
    }
}
