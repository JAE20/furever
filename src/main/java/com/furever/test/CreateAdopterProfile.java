package com.furever.test;

import com.furever.crud.AdopterCRUD;
import com.furever.models.Adopter;

public class CreateAdopterProfile {
    public static void main(String[] args) {
        System.out.println("Creating adopter profile for adopter1...");
        
        AdopterCRUD adopterCRUD = new AdopterCRUD();
        
        // Check if adopter1 profile already exists
        Adopter existing = adopterCRUD.getAdopterByUsername("adopter1");
        if (existing != null) {
            System.out.println("✅ Adopter profile for adopter1 already exists!");
            System.out.println("Name: " + existing.getAdopterName());
            System.out.println("Email: " + existing.getAdopterEmail());
            return;
        }
        
        // Create new adopter profile
        Adopter newAdopter = new Adopter();
        newAdopter.setAdopterName("John Adopter");
        newAdopter.setAdopterContact("09171111111");
        newAdopter.setAdopterEmail("adopter1@example.com");
        newAdopter.setAdopterAddress("789 Pet Lover St., Quezon City");
        newAdopter.setAdopterUsername("adopter1");
        
        if (adopterCRUD.createAdopter(newAdopter)) {
            System.out.println("✅ Successfully created adopter profile for adopter1!");
            System.out.println("Name: " + newAdopter.getAdopterName());
            System.out.println("Contact: " + newAdopter.getAdopterContact());
            System.out.println("Email: " + newAdopter.getAdopterEmail());
            System.out.println("Address: " + newAdopter.getAdopterAddress());
        } else {
            System.out.println("❌ Failed to create adopter profile");
        }
    }
}