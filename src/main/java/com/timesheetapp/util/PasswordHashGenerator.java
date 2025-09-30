package com.timesheetapp.util;

/**
 * Utility to generate BCrypt password hashes for demo users
 * Run this class to generate hashes for the database
 */
public class PasswordHashGenerator {

    public static void main(String[] args) {
        System.out.println("Generating BCrypt password hashes for demo users:\n");

        String[] passwords = {
            "admin123",
            "manager123",
            "employee123"
        };

        String[] usernames = {
            "admin",
            "jsmith",
            "mjohnson"
        };

        for (int i = 0; i < passwords.length; i++) {
            String hash = PasswordUtil.hashPassword(passwords[i]);
            System.out.println(usernames[i] + " / " + passwords[i] + ":");
            System.out.println(hash);
            System.out.println();
        }

        System.out.println("\nUse these hashes in your database-schema.sql or update-passwords.sql");
    }
}