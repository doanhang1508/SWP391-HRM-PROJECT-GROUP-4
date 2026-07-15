import org.mindrot.jbcrypt.BCrypt;

public class SeedData {
    public static void main(String[] args) {
        String[] hashes = {
            "$2a$12$rYoA1kECJ6UezPnfPqISP.Gg1Goc4FUiqLGQIFBOHqFbiBis2C4.i", // admin
            "$2a$12$VmGdTMHeOmArIfaKnIm7KuR4IeZScPaJatyvb8aq6bQDqDUvU0FWe", // giam_doc
            "$2a$12$KlvlpagR4obNSuv2XfM32uWEVqKfNFT5t5JUzRMCrYGi.1QetPgEy", // hr_manager
            "$2a$12$Pz91uQpiTf8GgwrkbiA/ReDRjxRk48K4lu2Y5yxLGlxQQutJ2xUIm", // quan_doc
            "$2a$12$9rsQL.viVSSU3uxAqO4aI.LVVYSyc6i1BaZSvrF5SPnAKijaaMmFK", // cong_nhan
            "$2a$12$TU4.I9PDJz5rYNR1fF7QNeAOwik010Ta6Pvihh7xhZHA3mmLxWF0C"  // hr_staff_01
        };
        String[] users = {"admin", "giam_doc", "hr_manager", "quan_doc", "cong_nhan", "hr_staff_01"};
        
        String[] candidates = {"@123456", "123456", "admin", "admin123", "password", "123"};
        
        for (int i = 0; i < hashes.length; i++) {
            System.out.println("Checking for " + users[i] + ": " + hashes[i]);
            boolean found = false;
            for (String cand : candidates) {
                try {
                    if (BCrypt.checkpw(cand, hashes[i])) {
                        System.out.println("  => FOUND PASSWORD: " + cand);
                        found = true;
                        break;
                    }
                } catch (Exception e) {}
            }
            if (!found) {
                System.out.println("  => NOT FOUND in candidate list");
            }
        }
    }
}
