package com.pairing.buds.domain.letter.dto.res;

import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterStatus;
import com.pairing.buds.domain.user.dto.response.UserDto;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Valid
public class GetLetterDetailResDto {

    private int letterId;

    private UserDto sender;

    private UserDto receiver;

    private String content;

    private LetterStatus status;

    @DateTimeFormat(pattern = "yyyy.MM.dd HH:mm:ss")
    private LocalDateTime createdAt;

    public static GetLetterDetailResDto toDto(Letter letter){
        GetLetterDetailResDto response = new GetLetterDetailResDto();
        response.setLetterId(letter.getId());
        response.setSender(UserDto.toDto(letter.getSender()));
        response.setReceiver(UserDto.toDto(letter.getReceiver()));
        response.setContent(letter.getContent());
        response.setStatus(letter.getStatus());
        response.setCreatedAt(letter.getCreatedAt());
        return response;
    }

}

