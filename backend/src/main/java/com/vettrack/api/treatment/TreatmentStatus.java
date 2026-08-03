package com.vettrack.api.treatment;

/**
 * Tedavi durumu. Ekip lideri talebi doğrultusunda 4 durum tanımlanmıştır.
 * Varsayılan değer: PLANNED (migration'da DEFAULT 'PLANNED').
 */
public enum TreatmentStatus {
    PLANNED,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED
}