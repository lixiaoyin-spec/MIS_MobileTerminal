package com.example.springbootapp.security;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TokenUser {
    private Long userId;
    private String username;
    private String role;
}

