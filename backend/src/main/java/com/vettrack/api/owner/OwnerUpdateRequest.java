package com.vettrack.api.owner;

import lombok.Data;

@Data
public class OwnerUpdateRequest {

    private String fullName;
    private String phone;
}