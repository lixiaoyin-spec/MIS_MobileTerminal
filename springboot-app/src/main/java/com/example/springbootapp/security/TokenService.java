package com.example.springbootapp.security;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class TokenService {
    private final Map<String, TokenUser> tokenStore = new ConcurrentHashMap<>();

    public void storeToken(String token, TokenUser user) {
        tokenStore.put(token, user);
    }

    public Optional<TokenUser> getUserByToken(String token) {
        return Optional.ofNullable(tokenStore.get(token));
    }

    public void removeToken(String token) {
        tokenStore.remove(token);
    }
}

