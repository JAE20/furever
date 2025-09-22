# 🔧 TROUBLESHOOTING GUIDE: ./runme Script Issues

## 🔍 Common Issues and Solutions

### Issue 1: Permission Denied
**Error**: `./runme: Permission denied`
**Solution**:
```bash
chmod +x runme
./runme
```

### Issue 2: Script Not Found
**Error**: `./runme: No such file or directory`
**Solution**:
```bash
# Make sure you're in the correct directory
cd /Users/jerimiahtongco/Desktop/furever
ls -la runme  # Should show the file exists
./runme
```

### Issue 3: MySQL Connector Not Found
**Error**: `mysql-connector-j-9.4.0.jar not found` or `ClassNotFoundException`
**Solution**:
```bash
# Check if the MySQL connector exists
ls -la mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar

# If missing, you need to download it again
# The correct path should be: mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar
```

### Issue 4: Java Version Compatibility
**Error**: `Unsupported major.minor version` or Java compilation errors
**Solution**:
```bash
# Check Java version
java -version
javac -version

# Make sure you're using Java 11 or higher
```

### Issue 5: Database Connection Issues
**Error**: `Failed to connect to database` or `Access denied for user`
**Solution**:
```bash
# Check if MySQL is running
# Make sure your database 'furever' exists
# Verify database credentials in DbConnection.java
```

### Issue 6: Compilation Errors
**Error**: Various Java compilation errors
**Solution**:
```bash
# Clean and rebuild
rm -rf target/classes/*
./runme
```

## 🛠️ Alternative Manual Commands

If the script continues to have issues, you can run the commands manually:

```bash
# Step 1: Create target directory
mkdir -p target/classes

# Step 2: Compile Java files
javac -cp "mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar:." -d target/classes src/main/java/com/furever/*.java src/main/java/com/furever/*/*.java

# Step 3: Run the application
java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.MainMenu
```

## 🔧 Debugging Steps

1. **Check current directory**:
   ```bash
   pwd
   ls -la
   ```

2. **Verify file structure**:
   ```bash
   ls -la src/main/java/com/furever/
   ls -la mysql-connector-j-9.4.0/
   ```

3. **Test compilation separately**:
   ```bash
   javac -cp "mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar:." -d target/classes src/main/java/com/furever/*.java src/main/java/com/furever/*/*.java
   echo $?  # Should return 0 if successful
   ```

4. **Test database connection**:
   ```bash
   java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.test.TestUserData
   ```

## 📞 What to Do Next

Please run these diagnostic commands and share the output:

```bash
cd /Users/jerimiahtongco/Desktop/furever
pwd
ls -la runme
ls -la mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar
java -version
./runme
```

This will help identify the specific issue you're experiencing.