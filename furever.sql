-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 22, 2025 at 05:12 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `furever`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adopter`
--

CREATE TABLE `tbl_adopter` (
  `adopter_id` int(11) NOT NULL,
  `adopter_name` varchar(100) NOT NULL,
  `adopter_contact` varchar(15) DEFAULT NULL,
  `adopter_email` varchar(100) DEFAULT NULL,
  `adopter_address` varchar(255) DEFAULT NULL,
  `adopter_profile` text DEFAULT NULL,
  `adopter_username` varchar(50) DEFAULT NULL,
  `adopter_password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adopter`
--

INSERT INTO `tbl_adopter` (`adopter_id`, `adopter_name`, `adopter_contact`, `adopter_email`, `adopter_address`, `adopter_profile`, `adopter_username`, `adopter_password`) VALUES
(1, 'Alice Johnson', '09171234567', 'alice@example.com', '123 Manila St.', NULL, 'alicej', 'password123'),
(2, 'Mark Cruz', '09281234567', 'mark@example.com', '456 Quezon Ave.', NULL, 'markc', 'password123');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adoption`
--

CREATE TABLE `tbl_adoption` (
  `adoption_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `adopter_id` int(11) NOT NULL,
  `adoption_date` date DEFAULT NULL,
  `upload_adoption_document` text DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adoption`
--

INSERT INTO `tbl_adoption` (`adoption_id`, `pet_id`, `adopter_id`, `adoption_date`, `upload_adoption_document`, `remarks`, `user_id`) VALUES
(1, 2, 2, '2025-09-15', NULL, 'Mittens officially adopted', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adoption_request`
--

CREATE TABLE `tbl_adoption_request` (
  `adoption_request_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `adopter_id` int(11) NOT NULL,
  `request_date` date DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `approval_date` date DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adoption_request`
--

INSERT INTO `tbl_adoption_request` (`adoption_request_id`, `pet_id`, `adopter_id`, `request_date`, `status`, `approval_date`, `remarks`, `user_id`) VALUES
(1, 1, 1, '2025-09-10', 'Pending', NULL, 'First request for Buddy', NULL),
(2, 2, 2, '2025-09-12', 'Approved', NULL, 'Approved request for Mittens', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pet`
--

CREATE TABLE `tbl_pet` (
  `pet_id` int(11) NOT NULL,
  `pet_owner_id` int(11) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `pet_type_id` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` enum('Male','Female') DEFAULT NULL,
  `health_status` enum('Healthy','Needs Treatment') DEFAULT NULL,
  `upload_health_history` text DEFAULT NULL,
  `vaccination_status` enum('Vaccinated','Not Vaccinated') DEFAULT NULL,
  `proof_of_vaccination` text DEFAULT NULL,
  `adoption_status` enum('Available','Pending','Adopted') DEFAULT 'Available',
  `date_registered` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pet`
--

INSERT INTO `tbl_pet` (`pet_id`, `pet_owner_id`, `pet_name`, `pet_type_id`, `description`, `age`, `gender`, `health_status`, `upload_health_history`, `vaccination_status`, `proof_of_vaccination`, `adoption_status`, `date_registered`) VALUES
(1, 1, 'Buddy', 1, 'Friendly golden retriever', 3, 'Male', 'Healthy', NULL, 'Vaccinated', NULL, 'Available', '2025-09-01'),
(2, 1, 'Mittens', 2, 'Playful Persian cat', 2, 'Female', 'Healthy', NULL, 'Not Vaccinated', NULL, 'Available', '2025-09-05');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pet_media`
--

CREATE TABLE `tbl_pet_media` (
  `pet_media_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `pet_media_name` varchar(255) DEFAULT NULL,
  `pet_media_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pet_media`
--

INSERT INTO `tbl_pet_media` (`pet_media_id`, `pet_id`, `pet_media_name`, `pet_media_url`) VALUES
(1, 1, 'Buddy Photo', 'uploads/buddy.jpg'),
(2, 2, 'Mittens Photo', 'uploads/mittens.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pet_owner`
--

CREATE TABLE `tbl_pet_owner` (
  `pet_owner_id` int(11) NOT NULL,
  `pet_owner_name` varchar(100) NOT NULL,
  `pet_owner_contact` varchar(15) DEFAULT NULL,
  `pet_owner_email` varchar(100) DEFAULT NULL,
  `pet_owner_address` varchar(255) DEFAULT NULL,
  `pet_owner_profile` text DEFAULT NULL,
  `pet_owner_username` varchar(50) DEFAULT NULL,
  `pet_owner_password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pet_owner`
--

INSERT INTO `tbl_pet_owner` (`pet_owner_id`, `pet_owner_name`, `pet_owner_contact`, `pet_owner_email`, `pet_owner_address`, `pet_owner_profile`, `pet_owner_username`, `pet_owner_password`) VALUES
(1, 'Juan Dela Cruz', '09181234567', 'juan@example.com', '789 Pasig Blvd.', NULL, 'juandc', 'password123');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pet_type`
--

CREATE TABLE `tbl_pet_type` (
  `pet_type_id` int(11) NOT NULL,
  `pet_type_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pet_type`
--

INSERT INTO `tbl_pet_type` (`pet_type_id`, `pet_type_name`) VALUES
(1, 'Dog'),
(2, 'Cat');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','adopter') DEFAULT 'adopter',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'admin1', 'admin1@example.com', 'admin123', 'admin', '2025-09-22 02:57:34'),
(2, 'adopter1', 'adopter1@example.com', 'adopter123', 'adopter', '2025-09-22 02:57:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_adopter`
--
ALTER TABLE `tbl_adopter`
  ADD PRIMARY KEY (`adopter_id`),
  ADD UNIQUE KEY `adopter_username` (`adopter_username`);

--
-- Indexes for table `tbl_adoption`
--
ALTER TABLE `tbl_adoption`
  ADD PRIMARY KEY (`adoption_id`),
  ADD KEY `fk_adoption_pet` (`pet_id`),
  ADD KEY `fk_adoption_adopter` (`adopter_id`);

--
-- Indexes for table `tbl_adoption_request`
--
ALTER TABLE `tbl_adoption_request`
  ADD PRIMARY KEY (`adoption_request_id`),
  ADD KEY `fk_request_pet` (`pet_id`),
  ADD KEY `fk_request_adopter` (`adopter_id`);

--
-- Indexes for table `tbl_pet`
--
ALTER TABLE `tbl_pet`
  ADD PRIMARY KEY (`pet_id`),
  ADD KEY `fk_pet_owner` (`pet_owner_id`),
  ADD KEY `fk_pet_type` (`pet_type_id`);

--
-- Indexes for table `tbl_pet_media`
--
ALTER TABLE `tbl_pet_media`
  ADD PRIMARY KEY (`pet_media_id`),
  ADD KEY `fk_pet_media` (`pet_id`);

--
-- Indexes for table `tbl_pet_owner`
--
ALTER TABLE `tbl_pet_owner`
  ADD PRIMARY KEY (`pet_owner_id`),
  ADD UNIQUE KEY `pet_owner_username` (`pet_owner_username`);

--
-- Indexes for table `tbl_pet_type`
--
ALTER TABLE `tbl_pet_type`
  ADD PRIMARY KEY (`pet_type_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_adopter`
--
ALTER TABLE `tbl_adopter`
  MODIFY `adopter_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tbl_adoption`
--
ALTER TABLE `tbl_adoption`
  MODIFY `adoption_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tbl_adoption_request`
--
ALTER TABLE `tbl_adoption_request`
  MODIFY `adoption_request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tbl_pet`
--
ALTER TABLE `tbl_pet`
  MODIFY `pet_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tbl_pet_media`
--
ALTER TABLE `tbl_pet_media`
  MODIFY `pet_media_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tbl_pet_owner`
--
ALTER TABLE `tbl_pet_owner`
  MODIFY `pet_owner_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tbl_pet_type`
--
ALTER TABLE `tbl_pet_type`
  MODIFY `pet_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_adoption`
--
ALTER TABLE `tbl_adoption`
  ADD CONSTRAINT `fk_adoption_adopter` FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`),
  ADD CONSTRAINT `fk_adoption_pet` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`);

--
-- Constraints for table `tbl_adoption_request`
--
ALTER TABLE `tbl_adoption_request`
  ADD CONSTRAINT `fk_request_adopter` FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`),
  ADD CONSTRAINT `fk_request_pet` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`);

--
-- Constraints for table `tbl_pet`
--
ALTER TABLE `tbl_pet`
  ADD CONSTRAINT `fk_pet_owner` FOREIGN KEY (`pet_owner_id`) REFERENCES `tbl_pet_owner` (`pet_owner_id`),
  ADD CONSTRAINT `fk_pet_type` FOREIGN KEY (`pet_type_id`) REFERENCES `tbl_pet_type` (`pet_type_id`);

--
-- Constraints for table `tbl_pet_media`
--
ALTER TABLE `tbl_pet_media`
  ADD CONSTRAINT `fk_pet_media` FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
