#!/bin/bash

echo "Compiling the Pet Adoption System..."
javac -cp "mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar:." -d target/classes src/main/java/com/furever/*.java src/main/java/com/furever/*/*.java

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    echo "Starting Pet Adoption System..."
    java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.MainMenu
else
    echo "Compilation failed. Please check for errors."
fi
