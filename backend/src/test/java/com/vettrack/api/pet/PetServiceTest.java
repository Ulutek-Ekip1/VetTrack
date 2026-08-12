package com.vettrack.api.pet;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.storage.StorageService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.time.Duration;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertTimeout;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PetServiceTest {

    @Mock
    private PetRepository petRepository;

    @Mock
    private StorageService storageService;

    @InjectMocks
    private PetService petService;

    private UUID mockOwnerId;

    @BeforeEach
    void setUp() {
        mockOwnerId = UUID.randomUUID();
    }

    @Test
    @DisplayName("Başkasının hayvanının fotoğrafı silinmeye çalışılırsa AccessDeniedException fırlatmalı")
    void testDeletePetPhoto_NotOwner_ThrowsAccessDenied() {
        UUID petId = UUID.randomUUID();
        UUID otherOwnerId = UUID.randomUUID();
        Pet pet = Pet.builder()
                .id(petId)
                .ownerId(mockOwnerId)
                .name("Duman")
                .gender(Gender.male)
                .photoUrl("https://storage.example.com/object/public/pet-photos/" + petId + ".jpg")
                .build();

        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));

        assertThatThrownBy(() -> petService.deletePetPhoto(petId, otherOwnerId))
                .isInstanceOf(AccessDeniedException.class);

        verify(storageService, never()).deletePetPhoto(anyString());
    }

    @Test
    @DisplayName("Fotoğrafı olmayan bir hayvanda silme işlemi Supabase'e istek atmadan sessizce başarılı olmalı")
    void testDeletePetPhoto_NoExistingPhoto_IsNoOp() {
        UUID petId = UUID.randomUUID();
        Pet pet = Pet.builder()
                .id(petId)
                .ownerId(mockOwnerId)
                .name("Duman")
                .gender(Gender.male)
                .photoUrl(null)
                .build();

        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));

        petService.deletePetPhoto(petId, mockOwnerId);

        verify(storageService, never()).deletePetPhoto(anyString());
        verify(petRepository, never()).save(any(Pet.class));
    }

    @Test
    @DisplayName("Fotoğrafı olan hayvanın sahibi sildiğinde StorageService çağrılmalı ve photoUrl temizlenmeli")
    void testDeletePetPhoto_HasPhoto_DeletesAndClearsUrl() {
        UUID petId = UUID.randomUUID();
        String photoUrl = "https://storage.example.com/object/public/pet-photos/" + petId + ".jpg?v=1";
        Pet pet = Pet.builder()
                .id(petId)
                .ownerId(mockOwnerId)
                .name("Duman")
                .gender(Gender.male)
                .photoUrl(photoUrl)
                .build();

        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));
        when(petRepository.save(any(Pet.class))).thenAnswer(invocation -> invocation.getArgument(0));

        petService.deletePetPhoto(petId, mockOwnerId);

        verify(storageService).deletePetPhoto(photoUrl);
        assertThat(pet.getPhotoUrl()).isNull();
        verify(petRepository).save(pet);
    }

    @Test
    @DisplayName("Benzersiz kod üretilmeli ve yasaklı karakterler (0, O, 1, I, L) içermemeli")
    void testGenerateUniqueCode_SuccessAndNoConfusingChars() {
        Pet newPet = Pet.builder()
                .ownerId(mockOwnerId)
                .name("Pamuk")
                .breed("Tekir")
                .species("Köpek")
                .gender(Gender.male)
                .build();

        when(petRepository.existsByUniqueCode(any())).thenReturn(false);
        when(petRepository.save(any(Pet.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Pet savedPet = petService.createPet(newPet);

        assertThat(savedPet.getUniqueCode()).isNotNull();
        assertThat(savedPet.getUniqueCode()).hasSize(6);
        assertThat(savedPet.getUniqueCode()).doesNotContain("0", "O", "1", "I", "L");
    }

    @Test
    @DisplayName("Ardışık 50 kayıt üretiminde hiçbir kod yasaklı karakter içermemeli ve hepsi benzersiz olmalı")
    void testGenerateUniqueCode_MultipleGenerations_NoForbiddenChars() {
        when(petRepository.existsByUniqueCode(any())).thenReturn(false);
        when(petRepository.save(any(Pet.class))).thenAnswer(invocation -> invocation.getArgument(0));

        for (int i = 0; i < 50; i++) {
            Pet pet = petService.createPet(Pet.builder()
                    .ownerId(UUID.randomUUID())
                    .name("Pet" + i)
                    .gender(Gender.unknown)
                    .build());

            assertThat(pet.getUniqueCode())
                    .hasSize(6)
                    .doesNotContain("0", "O", "1", "I", "L");
        }
    }

    @Test
    @DisplayName("Case-insensitive arama yapılabilmeli ve 1.5 saniyenin altında yanıt vermeli")
    void testGetPetByUniqueCode_CaseInsensitiveAndPerformance() {
        Pet pet = Pet.builder()
                .id(UUID.randomUUID())
                .ownerId(mockOwnerId)
                .name("Duman")
                .uniqueCode("ABCDEF")
                .gender(Gender.female)
                .build();

        when(petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(anyString()))
                .thenReturn(Optional.of(pet));

        assertTimeout(Duration.ofMillis(1500), () -> {
            Pet foundPet = petService.getPetByUniqueCode("abcdef");
            assertThat(foundPet).isNotNull();
            assertThat(foundPet.getId()).isEqualTo(pet.getId());
        });
    }

    @Test
    @DisplayName("Arama parametresindeki boşluklar temizlenmeli ve otomatik büyük harfe dönüştürülmeli")
    void testGetPetByUniqueCode_TrimAndUppercase() {
        Pet pet = Pet.builder()
                .id(UUID.randomUUID())
                .ownerId(mockOwnerId)
                .name("Mavi")
                .uniqueCode("XYZ123")
                .gender(Gender.unknown)
                .build();

        when(petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull("XYZ123"))
                .thenReturn(Optional.of(pet));

        Pet foundPet = petService.getPetByUniqueCode("   xyz123   ");

        assertThat(foundPet).isNotNull();
        assertThat(foundPet.getUniqueCode()).isEqualTo("XYZ123");
    }

    @Test
    @DisplayName("Boş veya null arama kodunda IllegalArgumentException fırlatmalı")
    void testGetPetByUniqueCode_BlankCode_ThrowsException() {
        assertThatThrownBy(() -> petService.getPetByUniqueCode("   "))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Arama kodu boş olamaz");
    }

    @Test
    @DisplayName("Veritabanında olmayan kod arandığında ResourceNotFoundException fırlatmalı")
    void testGetPetByUniqueCode_NotFound_ThrowsException() {
        when(petRepository.findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(anyString()))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> petService.getPetByUniqueCode("XXXXXX"))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}