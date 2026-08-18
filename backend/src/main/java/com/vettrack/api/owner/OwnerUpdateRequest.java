package com.vettrack.api.owner;

import lombok.Data;

@Data
public class OwnerUpdateRequest {

    private String fullName;
    private String name;
    private String surname;
    private String phone;
    private String address;
}