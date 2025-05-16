package com.pairing.buds.domain.letter.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterStatus;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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

    private boolean isScrapped;

    public static GetLetterDetailResDto toDto(Letter letter){
        GetLetterDetailResDto response = new GetLetterDetailResDto();
        response.setLetterId(letter.getId());
        response.setSenderName(letter.getSender().getUserName());
        response.setReceiverName(letter.getReceiver().getUserName());
        response.setContent(letter.getContent());
        response.setStatus(letter.getStatus());
        response.setCreatedAt(letter.getCreatedAt());
        response.setScrapped(letter.getIsScrapped());
        return response;
    }

}

