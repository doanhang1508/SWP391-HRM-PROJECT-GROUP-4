package model;

import java.math.BigDecimal;

public class PayrollConfig {
    private int id;
    private String configKey;
    private BigDecimal configValue;
    private String description;

    public PayrollConfig() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getConfigKey() {
        return configKey;
    }

    public void setConfigKey(String configKey) {
        this.configKey = configKey;
    }

    public BigDecimal getConfigValue() {
        return configValue;
    }

    public void setConfigValue(BigDecimal configValue) {
        this.configValue = configValue;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
