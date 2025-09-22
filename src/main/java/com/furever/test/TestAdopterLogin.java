package com.furever.test;

import com.furever.crud.UserCRUD;
import com.furever.models.User;

public class TestAdopterLogin {
    public static void main(String[] args) {
        UserCRUD userCRUD = new UserCRUD();
        
        System.out.println("Testing adopter authentication...");
        
        // Test with adopter1 credentials
        User user = userCRUD.authenticateUser("adopter1", "adopter123");
        
        if (user != null) {
            System.out.println("Authentication successful!");
            System.out.println("Username: " + user.getUsername());
            System.out.println("Role: " + user.getRole());
            System.out.println("Email: " + user.getEmail());
            
            if ("adopter".equals(user.getRole())) {
                System.out.println("✅ User has adopter role - login should work!");
            } else {
                System.out.println("❌ User does not have adopter role");
            }
        } else {
            System.out.println("❌ Authentication failed - user is null");
        }
    }
}