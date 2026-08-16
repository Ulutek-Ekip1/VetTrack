package com.vettrack.api.pet;

import com.vettrack.api.pet.dto.PetResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PetResponseTest {

    @Test
    @DisplayName("Pet entity'sinden PetResponse üretildiğinde tüm genel alanlar doğru aktarılmalı ve isActive/deletedAt sızdırılmamalı")
    void shouldMapPetEntityToPetResponseCorrectly() {
        UUID id = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        LocalDate birthDate = LocalDate.of(2021, 5, 10);
        OffsetDateTime now = OffsetDateTime.now();

        Pet pet = Pet.builder()
                .id(id)
                .ownerId(ownerId)
                .name("Boncuk")
                .species("Cat")
                .breed("Tabby")
                .gender(Gender.female)
                .birthDate(birthDate)
                .estimatedBirthYear((short) 2021)
                .photoUrl("https://example.com/photo.jpg")
                .weight(4.5)
                .microchipNo("900215000123456")
                .isSpayedOrNeutered(true)
                .bloodType("DEA 1.1 (+)")
                .color("Golden")
                .allergies("Tavuk alerjisi")
                .chronicIllnesses("Yok")
                .uniqueCode("ABC123")
                .isActive(true)
                .createdAt(now)
                .updatedAt(now)
                .deletedAt(null)
                .build();

        PetResponse response = PetResponse.fromEntity(pet);

        assertNotNull(response);
        assertEquals(id, response.getId());
        assertEquals(ownerId, response.getOwnerId());
        assertEquals("Boncuk", response.getName());
        assertEquals("Cat", response.getSpecies());
        assertEquals("Tabby", response.getBreed());
        assertEquals(Gender.female, response.getGender());
        assertEquals(birthDate, response.getBirthDate());
        assertEquals((short) 2021, response.getEstimatedBirthYear());
        assertEquals("https://example.com/photo.jpg", response.getPhotoUrl());
        assertEquals(4.5, response.getWeight());
        assertEquals("900215000123456", response.getMicrochipNo());
        assertEquals(true, response.getIsSpayedOrNeutered());
        assertEquals("DEA 1.1 (+)", response.getBloodType());
        assertEquals("Golden", response.getColor());
        assertEquals("Tavuk alerjisi", response.getAllergies());
        assertEquals("Yok", response.getChronicIllnesses());
        assertEquals("ABC123", response.getUniqueCode());
        assertEquals(now, response.getCreatedAt());
        assertEquals(now, response.getUpdatedAt());
    }

    @Test
    @DisplayName("null Pet entity verildiğinde null dönmeli")
    void shouldReturnNullWhenPetIsNull() {
        assertNull(PetResponse.fromEntity(null));
    }
}
