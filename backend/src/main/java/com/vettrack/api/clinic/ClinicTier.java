package com.vettrack.api.clinic;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ClinicTier {
    FREE(1, 50, 100),
    STARTER(2, 150, 500),
    STANDARD(5, 500, 2048),
    ENTERPRISE(Integer.MAX_VALUE, Integer.MAX_VALUE, 20480);

    private final int defaultMaxVets;
    private final int monthlyAiQuota;
    private final int storageLimitMb;

    @JsonValue
    public String toValue() {
        return name().toLowerCase();
    }

    @JsonCreator
    public static ClinicTier fromString(String value) {
        if (value == null) return FREE;
        for (ClinicTier tier : ClinicTier.values()) {
            if (tier.name().equalsIgnoreCase(value.trim())) {
                return tier;
            }
        }
        return FREE;
    }
}