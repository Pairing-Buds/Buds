package com.pairing.buds.domain.cs.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.answer.req.CreateAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.DeleteAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.PatchAnswerReqDto;
import com.pairing.buds.domain.cs.service.AnswerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

@RestController
@RequestMapping("/answers")
@RequiredArgsConstructor
public class AnswerController {

    @GetMapping("/test")
    public ResponseDto test(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test-final-1")
    public ResponseDto testFinal(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }



}
