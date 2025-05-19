package com.pairing.buds.domain.cs.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/answers")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AnswerController {
}
