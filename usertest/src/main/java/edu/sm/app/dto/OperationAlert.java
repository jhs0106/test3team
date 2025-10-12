package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;

@Getter
@Builder
@AllArgsConstructor
public class OperationAlert {
    private final String level;
    private final String message;
    private final Instant timestamp;
}