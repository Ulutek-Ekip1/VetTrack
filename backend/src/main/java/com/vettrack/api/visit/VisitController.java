package com.vettrack.api.visit;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/visits")
@RequiredArgsConstructor
public class VisitController {

    private final VisitService visitService;

    @PostMapping
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<Visit> createVisit(@Valid @RequestBody VisitCreateRequest request) {
        Visit visit = visitService.createVisit(
                request.getUniqueCode(),
                request.getVetStaffId(),
                request.getChiefComplaint()
        );
        return new ResponseEntity<>(visit, HttpStatus.CREATED);
    }

    @PutMapping("/{id}/close")
    @PreAuthorize("hasRole('VET_STAFF') or hasRole('ADMIN')")
    public ResponseEntity<Visit> closeVisit(@PathVariable UUID id) {
        Visit visit = visitService.closeVisit(id);
        return ResponseEntity.ok(visit);
    }

    @GetMapping("/code/{code}")
    public ResponseEntity<List<Visit>> getVisitsByCode(@PathVariable String code) {
        List<Visit> visits = visitService.getVisitsByUniqueCode(code);
        return ResponseEntity.ok(visits);
    }

    @GetMapping("/pet/{petId}")
    public ResponseEntity<List<Visit>> getVisitsByPetId(@PathVariable UUID petId) {
        List<Visit> visits = visitService.getVisitsByPetId(petId);
        return ResponseEntity.ok(visits);
    }
}