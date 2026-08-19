package com.vettrack.api.visit;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VisitCreateRequest {

    @NotNull(message = "Pet ID zorunludur.")
    private UUID petId;

    private UUID vetStaffId;
    private UUID clinicId;
    private String chiefComplaint;

    public static VisitCreateRequestBuilder builder() {
        return new VisitCreateRequestBuilder();
    }

    public static class VisitCreateRequestBuilder {
        private UUID petId;
        private UUID vetStaffId;
        private UUID clinicId;
        private String chiefComplaint;

        public VisitCreateRequestBuilder petId(UUID petId) { this.petId = petId; return this; }
        public VisitCreateRequestBuilder vetStaffId(UUID vetStaffId) { this.vetStaffId = vetStaffId; return this; }
        public VisitCreateRequestBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
        public VisitCreateRequestBuilder chiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; return this; }

        public VisitCreateRequest build() {
            VisitCreateRequest r = new VisitCreateRequest();
            r.petId = this.petId;
            r.vetStaffId = this.vetStaffId;
            r.clinicId = this.clinicId;
            r.chiefComplaint = this.chiefComplaint;
            return r;
        }
    }

    public UUID getPetId() { return petId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public UUID getVetStaffId() { return vetStaffId; }
    public void setVetStaffId(UUID vetStaffId) { this.vetStaffId = vetStaffId; }
    public UUID getClinicId() { return clinicId; }
    public void setClinicId(UUID clinicId) { this.clinicId = clinicId; }
    public String getChiefComplaint() { return chiefComplaint; }
    public void setChiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; }
}
