# Furever Pet Adoption System

A comprehensive console-based Java application for managing pet adoption processes in animal shelters and rescue centers.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Database Configuration](#database-configuration)
- [Running the Application](#running-the-application)
- [User Guide](#user-guide)
- [System Architecture](#system-architecture)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The Furever Pet Adoption System is designed to streamline the pet adoption process by providing a structured way to manage pets, adopters, and adoption requests. The system includes comprehensive CRUD operations, user authentication, and detailed reporting features.

## ✨ Features

### Core Functionality
- **User Management**: Admin login system with role-based access
- **Pet Management**: Complete pet profile management with health tracking
- **Adopter Management**: Comprehensive adopter information system
- **Adoption Request Management**: Full lifecycle management of adoption requests
- **Guest Access**: Limited read-only features for public viewing

### Key Capabilities
- ✅ CRUD operations for all entities
- ✅ Input validation and error handling
- ✅ Database connection management
- ✅ Real-time statistics and reporting
- ✅ Status tracking for pets and requests
- ✅ Search and filter functionality
- ✅ User-friendly console interface

## 📁 Project Structure

```
furever/
├── furever.sql                          # Database schema
├── README.md                           # This file
└── src/main/java/com/furever/
    ├── MainMenu.java                   # Main application entry point
    ├── database/
    │   └── DbConnection.java           # Database connection handler
    ├── models/                         # Data models
    │   ├── User.java
    │   ├── Adopter.java
    │   ├── Pet.java
    │   ├── PetType.java
    │   ├── PetOwner.java
    │   ├── AdoptionRequest.java
    │   ├── Adoption.java
    │   └── PetMedia.java
    ├── crud/                           # CRUD operations
    │   ├── UserCRUD.java
    │   ├── AdopterCRUD.java
    │   ├── PetCRUD.java
    │   ├── PetTypeCRUD.java
    │   └── AdoptionRequestCRUD.java
    ├── dashboard/                      # User interfaces
    │   ├── UserDashboard.java
    │   ├── AdopterDashboard.java
    │   ├── PetDashboard.java
    │   └── AdoptionRequestDashboard.java
    └── utils/
        └── InputValidator.java         # Input validation utilities
```

## 🔧 Prerequisites

- **Java Development Kit (JDK) 11 or higher**
- **MySQL Server 5.7 or higher**
- **MySQL JDBC Driver (mysql-connector-java)**
- **IDE with Java support** (VS Code, IntelliJ IDEA, Eclipse)

## 🚀 Setup Instructions

### 1. Database Setup

1. **Install MySQL Server** on your system
2. **Create the database**:
   ```sql
   CREATE DATABASE furever;
   ```
3. **Import the schema**:
   ```bash
   mysql -u root -p furever < furever.sql
   ```

### 2. Project Configuration

1. **Clone or download** the project files
2. **Add MySQL JDBC Driver** to your classpath:
   - Download `mysql-connector-java-8.0.x.jar`
   - Add to your project's classpath

### 3. Database Connection Configuration

Update the database connection settings in `DbConnection.java` if needed:

```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/furever";
private static final String DB_USERNAME = "root";
private static final String DB_PASSWORD = "your_password";
```

## 🗄️ Database Configuration

The system uses the following default configuration:
- **Host**: localhost
- **Port**: 3306
- **Database**: furever
- **Username**: root
- **Password**: (empty)

### Default Data

The database comes pre-populated with:
- **Admin User**: username: `admin1`, password: `admin123`
- **Sample Pet Types**: Dog, Cat
- **Sample Pets**: Buddy (Dog), Mittens (Cat)
- **Sample Adopters**: Alice Johnson, Mark Cruz

## ▶️ Running the Application

### Using Command Line

1. **Compile the Java files**:
   ```bash
   cd src/main/java
   javac -cp .:mysql-connector-java-8.0.x.jar com/furever/*.java com/furever/*/*.java
   ```

2. **Run the application**:
   ```bash
   java -cp .:mysql-connector-java-8.0.x.jar com.furever.MainMenu
   ```

### Using IDE

1. **Import the project** into your IDE
2. **Add MySQL JDBC driver** to the project libraries
3. **Run** the `MainMenu.java` class

## 📖 User Guide

### Login Options

1. **Admin Login**:
   - Use credentials: `admin1` / `admin123`
   - Full access to all system features

2. **Guest Access**:
   - View-only access to pets and basic statistics
   - No login required

### Admin Features

#### User Management
- Create, view, update, and delete user accounts
- Manage admin and adopter roles
- View user statistics

#### Pet Management
- Add new pets with complete profiles
- Update pet information and status
- Track adoption status (Available/Pending/Adopted)
- Search pets by various criteria

#### Adopter Management
- Register new adopters
- Maintain adopter contact information
- Track adopter history

#### Adoption Request Management
- Create adoption requests
- Approve or reject requests
- Track request status and history
- Generate adoption reports

### Navigation

- Use **number keys** to select menu options
- Press **Enter** to confirm selections
- Follow on-screen prompts for data entry
- Use **Ctrl+C** to exit the application

## 🏗️ System Architecture

### Design Patterns Used

- **MVC Pattern**: Separation of models, views (dashboards), and controllers (CRUD)
- **Singleton Pattern**: Database connection management
- **DAO Pattern**: Data access object pattern for database operations

### Database Design

- **Normalized schema** with proper foreign key relationships
- **Referential integrity** maintained across all tables
- **Optimized indexes** for better query performance

### Error Handling

- **Input validation** for all user inputs
- **Database error handling** with meaningful messages
- **Connection management** with automatic cleanup
- **Exception handling** throughout the application

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check MySQL service is running
   - Verify database credentials in `DbConnection.java`
   - Ensure database `furever` exists

2. **ClassNotFoundException: MySQL Driver**
   - Add `mysql-connector-java.jar` to classpath
   - Verify JDBC driver version compatibility

3. **Access Denied for User**
   - Check MySQL user permissions
   - Update password in `DbConnection.java`

4. **Table Doesn't Exist**
   - Import the `furever.sql` file
   - Check database name is correct

### Performance Tips

- **Connection Pooling**: For production use, implement connection pooling
- **Batch Operations**: For bulk data operations, use batch processing
- **Index Optimization**: Monitor query performance and add indexes as needed

## 📈 Future Enhancements

- Web-based interface
- Email notifications for adoption updates
- Photo upload functionality
- Advanced reporting and analytics
- Multi-location support
- Mobile application

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is developed for educational purposes. Feel free to use and modify as needed.

## 📞 Support

For issues or questions, please check the troubleshooting section or contact the development team.

---

**Furever Pet Adoption System** - Helping pets find their forever homes! 🐾