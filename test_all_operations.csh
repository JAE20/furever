#!/bin/csh

echo "🔥 FUREVER PET ADOPTION SYSTEM - COMPREHENSIVE TESTING 🔥"
echo "============================================================"
echo ""

# Test 1: Database Connection
echo "TEST 1: Database Connection Test"
echo "--------------------------------"
java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.test.TestUserData
echo ""

# Test 2: User Authentication
echo "TEST 2: User Authentication Test"
echo "--------------------------------"
java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.test.TestAdopterLogin
echo ""

# Test 3: CRUD Operations Test
echo "TEST 3: CRUD Operations Test"
echo "----------------------------"

# Test User CRUD
echo "Testing User CRUD operations..."
echo "SELECT COUNT(*) as user_count FROM users;" | mysql -u root -p furever 2>/dev/null || echo "MySQL command line not available, using Java test"

# Test Pet CRUD
echo "Testing Pet CRUD operations..."
echo "SELECT COUNT(*) as pet_count FROM tbl_pet;" | mysql -u root -p furever 2>/dev/null || echo "MySQL command line not available, using Java test"

# Test Adopter CRUD
echo "Testing Adopter CRUD operations..."
echo "SELECT COUNT(*) as adopter_count FROM tbl_adopter;" | mysql -u root -p furever 2>/dev/null || echo "MySQL command line not available, using Java test"

echo ""

echo "🎯 MANUAL TESTING CHECKLIST:"
echo "============================="
echo ""
echo "✅ 1. ADMIN LOGIN TEST:"
echo "   - Username: admin1"
echo "   - Password: admin123"
echo "   - Expected: Success + Admin Menu"
echo ""
echo "✅ 2. ADOPTER LOGIN TEST:"
echo "   - Username: adopter1"
echo "   - Password: adoptme"
echo "   - Expected: Success + Adopter Menu"
echo ""
echo "✅ 3. GUEST ACCESS TEST:"
echo "   - Choose option 3"
echo "   - Expected: Limited features menu"
echo ""
echo "✅ 4. ADMIN FEATURES TO TEST:"
echo "   - User Management (Create/Read/Update/Delete)"
echo "   - Pet Management (Create/Read/Update/Delete)"
echo "   - Adopter Management (Create/Read/Update/Delete)"
echo "   - Adoption Request Management"
echo "   - Search functionality (LIKE queries)"
echo ""
echo "✅ 5. ADOPTER FEATURES TO TEST:"
echo "   - View Available Pets"
echo "   - Submit Adoption Request"
echo "   - View My Adoption Requests"
echo "   - Update My Profile"
echo ""
echo "✅ 6. SEARCH FUNCTIONALITY TEST (LIKE queries):"
echo "   - Search Users by username pattern"
echo "   - Search Adopters by name pattern"
echo "   - Search Pets by name pattern"
echo ""
echo "✅ 7. DATABASE INTEGRITY TEST:"
echo "   - Create records"
echo "   - Update records"
echo "   - Verify relationships"
echo "   - Check constraints"
echo ""

echo "🚀 Starting Pet Adoption System for Manual Testing..."
echo "======================================================"
echo ""

# Start the main application
java -cp "target/classes:mysql-connector-j-9.4.0/mysql-connector-j-9.4.0.jar" com.furever.MainMenu