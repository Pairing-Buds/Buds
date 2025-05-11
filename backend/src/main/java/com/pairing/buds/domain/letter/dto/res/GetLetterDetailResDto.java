package com.pairing.buds.domain.letter.dto.res;

import com.fasterxml.jackson.annotation.JsonFormat;
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

    private String senderName;

    private String receiverName;

    private String content;

    private LetterStatus status;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDateTime createdAt;

    public static GetLetterDetailResDto toDto(Letter letter){
        GetLetterDetailResDto response = new GetLetterDetailResDto();
        response.setLetterId(letter.getId());
        response.setSenderName(letter.getSender().getUserName());
        response.setReceiverName(letter.getReceiver().getUserName());
        response.setContent(letter.getContent());
        response.setStatus(letter.getStatus());
        response.setCreatedAt(letter.getCreatedAt());
        return response;
    }

}

