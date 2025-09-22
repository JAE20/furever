package com.furever.test;

import com.furever.crud.*;
import com.furever.models.*;
import java.util.List;

public class TestAllOperations {
    public static void main(String[] args) {
        System.out.println("🔥 FUREVER PET ADOPTION SYSTEM - COMPREHENSIVE TESTING 🔥");
        System.out.println("============================================================\n");
        
        // Test 1: Database Connection
        testDatabaseConnection();
        
        // Test 2: User Authentication
        testUserAuthentication();
        
        // Test 3: CRUD Operations
        testCRUDOperations();
        
        // Test 4: Search Functionality
        testSearchFunctionality();
        
        System.out.println("\n🎉 ALL AUTOMATED TESTS COMPLETED!");
        System.out.println("For full testing, run the main application manually.");
    }
    
    private static void testDatabaseConnection() {
        System.out.println("TEST 1: Database Connection");
        System.out.println("---------------------------");
        
        try {
            UserCRUD userCRUD = new UserCRUD();
            List<User> users = userCRUD.getAllUsers();
            System.out.println("✅ Database connection successful!");
            System.out.println("✅ Found " + users.size() + " users in database");
            
            PetCRUD petCRUD = new PetCRUD();
            List<Pet> pets = petCRUD.getAllPets();
            System.out.println("✅ Found " + pets.size() + " pets in database");
            
            AdopterCRUD adopterCRUD = new AdopterCRUD();
            List<Adopter> adopters = adopterCRUD.getAllAdopters();
            System.out.println("✅ Found " + adopters.size() + " adopters in database");
            
        } catch (Exception e) {
            System.out.println("❌ Database connection failed: " + e.getMessage());
        }
        System.out.println();
    }
    
    private static void testUserAuthentication() {
        System.out.println("TEST 2: User Authentication");
        System.out.println("---------------------------");
        
        UserCRUD userCRUD = new UserCRUD();
        
        // Test admin login
        User admin = userCRUD.authenticateUser("admin1", "admin123");
        if (admin != null && "admin".equals(admin.getRole())) {
            System.out.println("✅ Admin authentication successful: " + admin.getUsername());
        } else {
            System.out.println("❌ Admin authentication failed");
        }
        
        // Test adopter login
        User adopter = userCRUD.authenticateUser("adopter1", "adoptme");
        if (adopter != null && "adopter".equals(adopter.getRole())) {
            System.out.println("✅ Adopter authentication successful: " + adopter.getUsername());
        } else {
            System.out.println("❌ Adopter authentication failed");
        }
        System.out.println();
    }
    
    private static void testCRUDOperations() {
        System.out.println("TEST 3: CRUD Operations");
        System.out.println("-----------------------");
        
        // Test User CRUD
        UserCRUD userCRUD = new UserCRUD();
        try {
            User testUser = userCRUD.getUserById(1);
            if (testUser != null) {
                System.out.println("✅ User READ operation successful: " + testUser.getUsername());
            } else {
                System.out.println("❌ User READ operation failed");
            }
        } catch (Exception e) {
            System.out.println("❌ User CRUD error: " + e.getMessage());
        }
        
        // Test Pet CRUD
        PetCRUD petCRUD = new PetCRUD();
        try {
            Pet testPet = petCRUD.getPetById(1);
            if (testPet != null) {
                System.out.println("✅ Pet READ operation successful: " + testPet.getPetName());
            } else {
                System.out.println("❌ Pet READ operation failed");
            }
        } catch (Exception e) {
            System.out.println("❌ Pet CRUD error: " + e.getMessage());
        }
        
        // Test Adopter CRUD
        AdopterCRUD adopterCRUD = new AdopterCRUD();
        try {
            Adopter testAdopter = adopterCRUD.getAdopterById(1);
            if (testAdopter != null) {
                System.out.println("✅ Adopter READ operation successful: " + testAdopter.getAdopterName());
            } else {
                System.out.println("❌ Adopter READ operation failed");
            }
        } catch (Exception e) {
            System.out.println("❌ Adopter CRUD error: " + e.getMessage());
        }
        System.out.println();
    }
    
    private static void testSearchFunctionality() {
        System.out.println("TEST 4: Search Functionality (LIKE queries)");
        System.out.println("--------------------------------------------");
        
        // Test User search
        UserCRUD userCRUD = new UserCRUD();
        try {
            List<User> searchResults = userCRUD.searchUsersByUsername("admin");
            System.out.println("✅ User LIKE search successful: Found " + searchResults.size() + " users matching 'admin'");
        } catch (Exception e) {
            System.out.println("❌ User search error: " + e.getMessage());
        }
        
        // Test Adopter search
        AdopterCRUD adopterCRUD = new AdopterCRUD();
        try {
            List<Adopter> searchResults = adopterCRUD.searchAdoptersByName("John");
            System.out.println("✅ Adopter LIKE search successful: Found " + searchResults.size() + " adopters matching 'John'");
        } catch (Exception e) {
            System.out.println("❌ Adopter search error: " + e.getMessage());
        }
        
        // Test Pet search
        PetCRUD petCRUD = new PetCRUD();
        try {
            List<Pet> searchResults = petCRUD.searchPetsByName("B");
            System.out.println("✅ Pet LIKE search successful: Found " + searchResults.size() + " pets matching 'B'");
        } catch (Exception e) {
            System.out.println("❌ Pet search error: " + e.getMessage());
        }
        System.out.println();
    }
}