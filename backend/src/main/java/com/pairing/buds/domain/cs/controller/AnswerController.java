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

    @GetMapping("/test2")
    public ResponseDto test2(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test3")
    public ResponseDto test3(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test4")
    public ResponseDto test4(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test5")
    public ResponseDto test5(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test6")
    public ResponseDto test6(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test7")
    public ResponseDto test7(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    @GetMapping("/test8")
    public ResponseDto test8(){
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
}
