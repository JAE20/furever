package com.furever.test;

import com.furever.crud.AdopterCRUD;
import com.furever.models.Adopter;
import java.util.List;

public class TestAdopterSearch {
    public static void main(String[] args) {
        System.out.println("🔍 TESTING ADOPTER MANAGEMENT DASHBOARD - SEARCH BY NAME");
        System.out.println("=========================================================");
        System.out.println();
        
        AdopterCRUD adopterCRUD = new AdopterCRUD();
        
        try {
            // First, show all adopters
            System.out.println("📋 ALL ADOPTERS IN DATABASE:");
            System.out.println("-----------------------------");
            List<Adopter> allAdopters = adopterCRUD.getAllAdopters();
            
            if (allAdopters.isEmpty()) {
                System.out.println("❌ No adopters found in database");
                return;
            }
            
            System.out.printf("%-5s %-25s %-15s %-30s %-20s%n", 
                "ID", "Name", "Contact", "Email", "Username");
            System.out.println("-".repeat(95));
            
            for (Adopter adopter : allAdopters) {
                System.out.printf("%-5d %-25s %-15s %-30s %-20s%n",
                    adopter.getAdopterId(),
                    adopter.getAdopterName(),
                    adopter.getAdopterContact() != null ? adopter.getAdopterContact() : "N/A",
                    adopter.getAdopterEmail() != null ? adopter.getAdopterEmail() : "N/A",
                    adopter.getAdopterUsername() != null ? adopter.getAdopterUsername() : "N/A");
            }
            
            System.out.println();
            
            // Test different search patterns
            testSearchPattern(adopterCRUD, "John");
            testSearchPattern(adopterCRUD, "Alice");
            testSearchPattern(adopterCRUD, "A");
            testSearchPattern(adopterCRUD, "Johnson");
            testSearchPattern(adopterCRUD, "Mark");
            testSearchPattern(adopterCRUD, "Cruz");
            testSearchPattern(adopterCRUD, "xyz"); // Should find nothing
            
        } catch (Exception e) {
            System.out.println("❌ Error testing adopter search: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void testSearchPattern(AdopterCRUD adopterCRUD, String searchTerm) {
        System.out.println("🔍 SEARCH TEST: Pattern = '" + searchTerm + "'");
        System.out.println("SQL Query: SELECT * FROM tbl_adopter WHERE adopter_name LIKE '%" + searchTerm + "%'");
        
        try {
            List<Adopter> results = adopterCRUD.searchAdoptersByName(searchTerm);
            
            if (results.isEmpty()) {
                System.out.println("❌ No adopters found matching: " + searchTerm);
            } else {
                System.out.println("✅ Found " + results.size() + " adopter(s) matching '" + searchTerm + "':");
                System.out.printf("   %-5s %-25s %-30s%n", "ID", "Name", "Email");
                System.out.println("   " + "-".repeat(60));
                
                for (Adopter adopter : results) {
                    System.out.printf("   %-5d %-25s %-30s%n",
                        adopter.getAdopterId(),
                        adopter.getAdopterName(),
                        adopter.getAdopterEmail() != null ? adopter.getAdopterEmail() : "N/A");
                }
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error searching for '" + searchTerm + "': " + e.getMessage());
        }
        
        System.out.println();
    }
}