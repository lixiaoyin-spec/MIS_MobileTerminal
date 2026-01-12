package com.example.springbootapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result<T> {
    private Integer code; // 200 for success, other for failure
    private String msg;   // response message
    private T data;       // response data

    public static <E> Result<E> success(E data) {
        return new Result<>(200, "success", data);
    }

    public static Result<?> error(String msg) {
        return new Result<>(500, msg, null);
    }
}
