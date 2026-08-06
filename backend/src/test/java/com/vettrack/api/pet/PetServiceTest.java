package com.vettrack.api.pet;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.storage.StorageService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PetServiceTest {

    @Mock
    private PetRepository petRepository;

    @Mock
    private StorageService storageService;

    @InjectMocks
    private PetService petService;

    @Test
    @DisplayName("Gelen arama kodu başındaki ve sonundaki boşluklardan arındırılmalı (trim) ve büyük harfe çevrilmeli (uppercase)")
    void testGetPetByUniqueCode_TrimAndUppercase() {
        String rawInputCode = "   xyz123   ";
        String expectedSanitizedCode = "XYZ123";

        Pet mockPet = Pet.builder()
                .id(UUID.randomUUID())
                .name("Pamuk")
                .uniqueCode(expectedSanitizedCode)
                .build();

        when(petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(expectedSanitizedCode))
                .thenReturn(Optional.of(mockPet));

        Pet result = petService.getPetByUniqueCode(rawInputCode);

        assertNotNull(result);
        assertEquals("Pamuk", result.getName());
        assertEquals(expectedSanitizedCode, result.getUniqueCode());

        verify(petRepository, times(1)).findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(expectedSanitizedCode);
    }

    @Test
    @DisplayName("Boş veya sadece boşluklardan oluşan kod ile arama yapıldığında IllegalArgumentException fırlatılmalı")
    void testGetPetByUniqueCode_BlankCode_ThrowsException() {
        IllegalArgumentException ex1 = assertThrows(
                IllegalArgumentException.class,
                () -> petService.getPetByUniqueCode("   ")
        );
        assertEquals("Arama kodu boş olamaz", ex1.getMessage());

        IllegalArgumentException ex2 = assertThrows(
                IllegalArgumentException.class,
                () -> petService.getPetByUniqueCode(null)
        );
        assertEquals("Arama kodu boş olamaz", ex2.getMessage());

        verify(petRepository, never()).findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(any());
    }

    @Test
    @DisplayName("Var olmayan benzersiz kod ile arama yapıldığında ResourceNotFoundException fırlatılmalı")
    void testGetPetByUniqueCode_NotFound_ThrowsException() {
        when(petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull("NOTFND"))
                .thenReturn(Optional.empty());

        assertThrows(
                ResourceNotFoundException.class,
                () -> petService.getPetByUniqueCode("NOTFND")
        );
    }
}
