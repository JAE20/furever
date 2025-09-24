package com.furever.test;

import com.furever.crud.UserCRUD;
import com.furever.database.DbConnection;
import com.furever.models.User;

/**
 * Debug class for testing adopter login functionality
 */
public class AdopterLoginDebug {
    
    public static void main(String[] args) {
        System.out.println("=== ADOPTER LOGIN DEBUG TEST ===");
        
        // Test database connection
        try {
            if (DbConnection.testConnection()) {
                System.out.println("✅ Database connection successful");
            } else {
                System.out.println("❌ Database connection failed");
                return;
            }
        } catch (Exception e) {
            System.out.println("❌ Database connection error: " + e.getMessage());
            return;
        }
        
        UserCRUD userCRUD = new UserCRUD();
        
        // Test 1: Check if user exists with adopter role
        System.out.println("\n--- Test 1: Check adopter users ---");
        try {
            var allUsers = userCRUD.getAllUsers();
            System.out.println("Total users found: " + allUsers.size());
            
            for (User user : allUsers) {
                if ("adopter".equals(user.getRole())) {
                    System.out.println("Found adopter: " + user.getUsername() + " | " + user.getEmail() + " | Role: " + user.getRole());
                }
            }
        } catch (Exception e) {
            System.out.println("❌ Error getting users: " + e.getMessage());
        }
        
        // Test 2: Try authentication with known adopter credentials
        System.out.println("\n--- Test 2: Authentication test ---");
        String testUsername = "Adopter20";
        String testPassword = "adoptme";
        
        try {
            User authenticatedUser = userCRUD.authenticateUser(testUsername, testPassword);
            
            if (authenticatedUser != null) {
                System.out.println("✅ Authentication successful!");
                System.out.println("User ID: " + authenticatedUser.getId());
                System.out.println("Username: " + authenticatedUser.getUsername());
                System.out.println("Email: " + authenticatedUser.getEmail());
                System.out.println("Role: " + authenticatedUser.getRole());
                
                if ("adopter".equals(authenticatedUser.getRole())) {
                    System.out.println("✅ Role verification passed!");
                } else {
                    System.out.println("❌ Role verification failed - expected 'adopter', got '" + authenticatedUser.getRole() + "'");
                }
            } else {
                System.out.println("❌ Authentication failed for username: " + testUsername);
                
                // Try to find user by username only
                User userByUsername = userCRUD.getUserByUsername(testUsername);
                if (userByUsername != null) {
                    System.out.println("User exists but password doesn't match");
                    System.out.println("Expected password: " + testPassword);
                    System.out.println("Note: Check database for actual password");
                } else {
                    System.out.println("User '" + testUsername + "' not found in database");
                }
            }
        } catch (Exception e) {
            System.out.println("❌ Authentication error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Test 3: Check for constraint issues
        System.out.println("\n--- Test 3: Constraint check ---");
        try {
            // Try creating a test user to see if there are constraint issues
            User testUser = new User("test_adopter", "test@example.com", "testpass", "adopter");
            boolean created = userCRUD.createUser(testUser);
            
            if (created) {
                System.out.println("✅ Test user creation successful - no constraint issues");
                // Clean up test user
                userCRUD.deleteUser(testUser.getId());
            } else {
                System.out.println("❌ Test user creation failed - possible constraint issues");
            }
        } catch (Exception e) {
            System.out.println("❌ Constraint test error: " + e.getMessage());
        }
        
        System.out.println("\n=== DEBUG TEST COMPLETE ===");
    }
}