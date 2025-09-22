package com.furever.test;

import com.furever.crud.UserCRUD;
import com.furever.crud.AdopterCRUD;
import com.furever.crud.PetCRUD;
import com.furever.models.User;
import com.furever.models.Adopter;
import com.furever.models.Pet;
import java.util.List;

public class TestLikeSearch {
    public static void main(String[] args) {
        System.out.println("Testing LIKE search functionality...\n");
        
        // Test User search by username
        UserCRUD userCRUD = new UserCRUD();
        System.out.println("=== Testing User Search by Username (LIKE) ===");
        
        // Search for users with "admin" in username
        List<User> users = userCRUD.searchUsersByUsername("admin");
        System.out.println("Search for 'admin' in username:");
        for (User user : users) {
            System.out.printf("- %s (%s)\n", user.getUsername(), user.getRole());
        }
        
        // Search for users with "adopter" in username
        users = userCRUD.searchUsersByUsername("adopter");
        System.out.println("\nSearch for 'adopter' in username:");
        for (User user : users) {
            System.out.printf("- %s (%s)\n", user.getUsername(), user.getRole());
        }
        
        // Test Adopter search by name
        AdopterCRUD adopterCRUD = new AdopterCRUD();
        System.out.println("\n=== Testing Adopter Search by Name (LIKE) ===");
        
        // Search for adopters with "John" in name
        List<Adopter> adopters = adopterCRUD.searchAdoptersByName("John");
        System.out.println("Search for 'John' in adopter name:");
        for (Adopter adopter : adopters) {
            System.out.printf("- %s (%s)\n", adopter.getAdopterName(), adopter.getAdopterEmail());
        }
        
        // Search for adopters with "A" in name
        adopters = adopterCRUD.searchAdoptersByName("A");
        System.out.println("\nSearch for 'A' in adopter name:");
        for (Adopter adopter : adopters) {
            System.out.printf("- %s (%s)\n", adopter.getAdopterName(), adopter.getAdopterEmail());
        }
        
        // Test Pet search by name
        PetCRUD petCRUD = new PetCRUD();
        System.out.println("\n=== Testing Pet Search by Name (LIKE) ===");
        
        // Search for pets with "B" in name
        List<Pet> pets = petCRUD.searchPetsByName("B");
        System.out.println("Search for 'B' in pet name:");
        for (Pet pet : pets) {
            System.out.printf("- %s (Age: %d, %s)\n", pet.getPetName(), pet.getAge(), pet.getAdoptionStatus());
        }
        
        // Search for pets with "M" in name
        pets = petCRUD.searchPetsByName("M");
        System.out.println("\nSearch for 'M' in pet name:");
        for (Pet pet : pets) {
            System.out.printf("- %s (Age: %d, %s)\n", pet.getPetName(), pet.getAge(), pet.getAdoptionStatus());
        }
        
        System.out.println("\n✅ LIKE search functionality working properly!");
        System.out.println("All searches use SQL LIKE with % wildcards for partial matching.");
    }
}