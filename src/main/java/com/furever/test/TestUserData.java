package com.furever.test;

import com.furever.database.DbConnection;
import java.sql.*;

public class TestUserData {
    public static void main(String[] args) {
        System.out.println("Testing database connection and user data...");
        
        try (Connection conn = DbConnection.getConnection()) {
            System.out.println("✅ Database connection successful!");
            
            // Check what users exist
            String sql = "SELECT id, username, email, password, role FROM users";
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                
                System.out.println("\nUsers in database:");
                System.out.println("ID | Username | Email | Password | Role");
                System.out.println("-".repeat(60));
                
                while (rs.next()) {
                    System.out.printf("%d | %s | %s | %s | %s%n",
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role"));
                }
            }
            
            // Test specific query for adopter1
            System.out.println("\nTesting specific query for adopter1...");
            sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, "adopter1");
                pstmt.setString(2, "adopter123");
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("✅ Found adopter1 with correct password!");
                        System.out.println("Role: " + rs.getString("role"));
                    } else {
                        System.out.println("❌ adopter1 not found with those credentials");
                    }
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Database error: " + e.getMessage());
        }
    }
}