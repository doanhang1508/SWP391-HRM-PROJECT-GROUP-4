package util;

import dao.KpiDAO;
import model.KpiEvaluationItem;
import java.util.ArrayList;
import java.util.List;

public class TestDB {
    public static void main(String[] args) {
        try {
            KpiDAO dao = new KpiDAO();
            // Let's find an existing evaluation ID
            int evalId = 1; // Assuming 1 exists, let's verify or use the first one from DB
            List<model.KpiEvaluation> list = dao.getEvaluationsByCycle(1);
            if (!list.isEmpty()) {
                evalId = list.get(0).getEvaluationId();
            }
            System.out.println("Testing with evaluation ID: " + evalId);
            
            // Get original items
            List<KpiEvaluationItem> original = dao.getEvaluationItems(evalId);
            System.out.println("Original items count: " + original.size());
            if (!original.isEmpty()) {
                System.out.println("Original first item comment: " + original.get(0).getComment());
            }

            // Let's create dummy items with a comment
            List<KpiEvaluationItem> itemsToSave = new ArrayList<>();
            for (KpiEvaluationItem item : original) {
                KpiEvaluationItem copy = new KpiEvaluationItem(0, evalId, item.getTemplateItemId(), 8.0, "Test Comment 123");
                itemsToSave.add(copy);
            }

            boolean success = dao.saveOrUpdateEvaluationItems(evalId, itemsToSave, 1);
            System.out.println("Save success: " + success);

            // Fetch again
            List<KpiEvaluationItem> updated = dao.getEvaluationItems(evalId);
            if (!updated.isEmpty()) {
                System.out.println("Updated first item comment: " + updated.get(0).getComment());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
