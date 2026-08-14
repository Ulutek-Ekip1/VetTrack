package com.vettrack.api.ai;

import com.vettrack.api.ai.dto.AiChatResponse;
import com.vettrack.api.ai.service.EmergencySafetyService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

class EmergencySafetyServiceTest {

    private EmergencySafetyService emergencySafetyService;

    @BeforeEach
    void setUp() {
        emergencySafetyService = new EmergencySafetyService();
    }

    @Test
    void testRespiratoryCrisisDetected_ReturnsEmergencyAndBypassesApi() {
        long startTime = System.nanoTime();
        Optional<AiChatResponse> result = emergencySafetyService.checkEmergency("Kedim aniden nefes alamıyor ve morarmaya başladı");
        long durationMs = (System.nanoTime() - startTime) / 1_000_000;

        assertTrue(result.isPresent());
        assertTrue(result.get().isEmergency());
        assertTrue(result.get().getReply().contains("ACİL DURUM ALARMI"));
        assertTrue(durationMs < 50, "Execution time should be sub-5ms (threshold safe for test env)");
    }

    @Test
    void testToxicologyPoisoningDetected() {
        Optional<AiChatResponse> result = emergencySafetyService.checkEmergency("Köpeğim yanlışlıkla çamaşır suyu içti ne yapmalıyım");

        assertTrue(result.isPresent());
        assertTrue(result.get().isEmergency());
        assertTrue(result.get().getReply().contains("ZEHİRLENME ŞÜPHESİ"));
    }

    @Test
    void testTraumaBleedingDetected() {
        Optional<AiChatResponse> result = emergencySafetyService.checkEmergency("Kedime araba çarptı durmayan kanama var");

        assertTrue(result.isPresent());
        assertTrue(result.get().isEmergency());
        assertTrue(result.get().getReply().contains("TRAVMA / ŞİDDETLİ KANAMA"));
    }

    @Test
    void testRoutineSymptomPassesSafetyCheck() {
        Optional<AiChatResponse> result = emergencySafetyService.checkEmergency("Kedimin tüyleri çok dökülüyor hangi mamayı kullanmalıyım?");

        assertTrue(result.isEmpty(), "Routine non-emergency query must return empty to proceed to Gemini API");
    }
}
