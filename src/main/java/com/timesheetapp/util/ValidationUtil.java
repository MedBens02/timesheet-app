package com.timesheetapp.util;

import java.util.regex.Pattern;
import java.time.LocalDate;
import java.time.DayOfWeek;
import java.math.BigDecimal;

public class ValidationUtil {
    
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$");
    
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,50}$");
    
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }
    
    public static boolean isValidName(String name) {
        return name != null && name.trim().length() >= 2 && name.trim().length() <= 50;
    }
    
    public static boolean isValidHourlyRate(BigDecimal rate) {
        return rate != null && rate.compareTo(BigDecimal.ZERO) >= 0 && 
               rate.compareTo(new BigDecimal("1000")) <= 0;
    }
    
    public static boolean isValidHoursWorked(BigDecimal hours) {
        return hours != null && hours.compareTo(BigDecimal.ZERO) >= 0 && 
               hours.compareTo(new BigDecimal("24")) <= 0;
    }
    
    public static boolean isValidWeekStartDate(LocalDate date) {
        return date != null && date.getDayOfWeek() == DayOfWeek.MONDAY;
    }
    
    public static boolean isValidDateRange(LocalDate startDate, LocalDate endDate) {
        return startDate != null && endDate != null && !startDate.isAfter(endDate);
    }
    
    public static LocalDate getWeekStartDate(LocalDate date) {
        if (date == null) {
            return null;
        }
        return date.with(DayOfWeek.MONDAY);
    }
    
    public static LocalDate getWeekEndDate(LocalDate weekStartDate) {
        if (weekStartDate == null) {
            return null;
        }
        return weekStartDate.plusDays(6);
    }
    
    public static boolean isWorkDay(LocalDate date) {
        if (date == null) {
            return false;
        }
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        return dayOfWeek != DayOfWeek.SATURDAY && dayOfWeek != DayOfWeek.SUNDAY;
    }
    
    public static boolean isValidProjectName(String name) {
        return name != null && name.trim().length() >= 3 && name.trim().length() <= 100;
    }
    
    public static boolean isValidTaskName(String name) {
        return name != null && name.trim().length() >= 3 && name.trim().length() <= 100;
    }
    
    public static boolean isValidEstimatedHours(Integer hours) {
        return hours != null && hours >= 0 && hours <= 10000;
    }
    
    public static boolean isValidCost(BigDecimal cost) {
        return cost != null && cost.compareTo(BigDecimal.ZERO) >= 0 && 
               cost.compareTo(new BigDecimal("1000000")) <= 0;
    }
    
    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        return input.trim().replaceAll("[<>\"'&]", "");
    }
    
    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }
}