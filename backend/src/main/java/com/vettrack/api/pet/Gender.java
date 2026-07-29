package com.vettrack.api.pet;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum Gender {
    @JsonProperty("male")
    male,

    @JsonProperty("female")
    female,

    @JsonProperty("unknown")
    unknown
}
