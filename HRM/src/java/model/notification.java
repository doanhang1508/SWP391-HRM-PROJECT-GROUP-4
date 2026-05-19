/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.time.LocalDateTime;

/**
 *
 * @author Thanh Hang
 */
public class notification {
     private int           id;
    private int           userId;   
    private String        type;         // "attendance" | "leave" | "overtime" | "payroll"
                                        // "kpi" | "training" | "system" | "announcement" | "shift"
    private String        title;
    private String        body;
    private String        link;
    private boolean       isRead;
    private LocalDateTime createdAt;
 
    /** Trường tính toán — không ánh xạ DB, dùng để hiển thị trên UI */
    private String        timeAgo;
 
    // ── Constructors ────────────────────────────────────────
 
    public notification() {}
 
    public notification(int userId, String type, String title, String body, String link) {
        this.userId = userId;
        this.type       = type;
        this.title      = title;
        this.body       = body;
        this.link       = link;
    }
 
    // ── Getters & Setters ───────────────────────────────────
 
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
 
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
 
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
 
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
 
    public String getBody() {
        return body;
    }
    public void setBody(String body) {
        this.body = body;
    }
 
    public String getLink() {
        return link;
    }
    public void setLink(String link) {
        this.link = link;
    }
 
    public boolean isRead() {
        return isRead;
    }
    public void setRead(boolean read) {
        this.isRead = read;
    }
 
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
 
    public String getTimeAgo() {
        return timeAgo;
    }
    public void setTimeAgo(String timeAgo) {
        this.timeAgo = timeAgo;
    }
 
    // ── toString (debug) ────────────────────────────────────
 
    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", userId=" + userId +
                ", type='" + type + '\'' +
                ", title='" + title + '\'' +
                ", isRead=" + isRead +
                ", createdAt=" + createdAt +
                '}';
    }
}
